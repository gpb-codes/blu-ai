package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/rs/zerolog"

	"github.com/blu-ia/api/internal/application/usecases"
	"github.com/blu-ia/api/internal/config"
	"github.com/blu-ia/api/internal/domain/repositories"
	"github.com/blu-ia/api/internal/gateway"
	"github.com/blu-ia/api/internal/gateway/adapters"
	"github.com/blu-ia/api/internal/infrastructure/auth"
	"github.com/blu-ia/api/internal/infrastructure/database"
	infraRepo "github.com/blu-ia/api/internal/infrastructure/repositories"
	"github.com/blu-ia/api/internal/presentation/handlers"
	mw "github.com/blu-ia/api/internal/presentation/middleware"
)

func main() {
	logger := zerolog.New(os.Stdout).With().Timestamp().Logger()
	cfg := config.Load()

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pool, err := database.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		logger.Warn().Err(err).Msg("sin conexión a DB — modo degradado (health ok, otras rutas requieren DB)")
		pool = nil
	} else {
		defer pool.Close()
		logger.Info().Msg("conectado a PostgreSQL")
	}

	providers := adapters.CreateProviders()
	router := gateway.NewTierRouter(providers, gateway.DefaultTierRoutes())

	hasher := &auth.BcryptHasher{}
	jwtSvc := auth.NewJWTService(cfg.JWTSecret, cfg.JWTExpiresIn, cfg.JWTRefreshExpiresIn)
	cipher := auth.NewApiKeyCipher()

	var userRepo repositories.UserRepository
	var projectRepo repositories.ProjectRepository
	var vaultRepo repositories.VaultRepository
	var refreshRepo repositories.RefreshTokenRepository
	var accountRepo repositories.UserAccountRepository
	var sessionRepo repositories.ChatSessionRepository

	if pool != nil {
		userRepo = infraRepo.NewPGUserRepository(pool)
		projectRepo = infraRepo.NewPGProjectRepository(pool)
		vaultRepo = infraRepo.NewPGVaultRepository(pool)
		refreshRepo = infraRepo.NewPGRefreshTokenRepository(pool)
		accountRepo = infraRepo.NewPGUserAccountRepository(pool, cipher)
		sessionRepo = infraRepo.NewPGChatSessionRepository(pool)
	} else {
		userRepo = infraRepo.NewInMemoryUserRepo()
		projectRepo = infraRepo.NewInMemoryProjectRepo()
		vaultRepo = infraRepo.NewInMemoryVaultRepo()
		refreshRepo = infraRepo.NewInMemoryRefreshRepo()
		accountRepo = infraRepo.NewInMemoryUserAccountRepo()
		sessionRepo = infraRepo.NewInMemoryChatSessionRepo()
	}

	authUC := usecases.NewAuthUseCase(userRepo, refreshRepo, hasher, jwtSvc)
	chatUC := usecases.NewChatUseCase(router, vaultRepo, projectRepo)
	projectsUC := usecases.NewProjectsUseCase(projectRepo)
	vaultUC := usecases.NewVaultUseCase(vaultRepo, projectRepo)
	userUC := usecases.NewUserUseCase(userRepo, accountRepo)
	sessionsUC := usecases.NewChatSessionsUseCase(sessionRepo, projectRepo)

	authHandler := handlers.NewAuthHandler(authUC)
	chatHandler := handlers.NewChatHandler(chatUC)
	projectsHandler := handlers.NewProjectsHandler(projectsUC)
	vaultHandler := handlers.NewVaultHandler(vaultUC)
	userHandler := handlers.NewUserHandler(userUC)
	_ = sessionsUC

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   cfg.CORSOrigin,
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	r.Get("/health", handlers.Health)
	r.Route("/auth", func(ra chi.Router) {
		ra.Post("/register", authHandler.Register)
		ra.Post("/login", authHandler.Login)
		ra.Post("/refresh", authHandler.Refresh)
		ra.Post("/logout", authHandler.Logout)
		ra.With(mw.JWTAuth(jwtSvc)).Get("/me", authHandler.Me)
	})
	r.Route("/chat", func(rc chi.Router) {
		rc.Use(mw.JWTAuth(jwtSvc))
		rc.Post("/", chatHandler.Send)
	})
	r.Route("/projects", func(rp chi.Router) {
		rp.Use(mw.JWTAuth(jwtSvc))
		rp.Get("/", projectsHandler.List)
		rp.Post("/", projectsHandler.Create)
		rp.Get("/{id}", projectsHandler.Get)
		rp.Put("/{id}", projectsHandler.Update)
		rp.Delete("/{id}", projectsHandler.Delete)
		rp.Get("/{id}/members", projectsHandler.Members)
		rp.Post("/{id}/members", projectsHandler.AddMember)
		rp.Put("/{id}/members/{userId}", projectsHandler.UpdateMember)
		rp.Delete("/{id}/members/{userId}", projectsHandler.RemoveMember)
	})
	r.Route("/vault", func(rv chi.Router) {
		rv.Use(mw.JWTAuth(jwtSvc))
		rv.Get("/notes", vaultHandler.Notes)
		rv.Get("/search", vaultHandler.Search)
		rv.Get("/notes/{id}", vaultHandler.Get)
		rv.Post("/notes", vaultHandler.Create)
		rv.Put("/notes/{id}", vaultHandler.Update)
		rv.Delete("/notes/{id}", vaultHandler.Delete)
	})
	r.Route("/user", func(ru chi.Router) {
		ru.Use(mw.JWTAuth(jwtSvc))
		ru.Get("/profile", userHandler.Profile)
		ru.Put("/profile", userHandler.UpdateProfile)
		ru.Get("/api-keys", userHandler.ApiKeys)
		ru.Post("/api-keys", userHandler.AddApiKey)
		ru.Delete("/api-keys/{provider}", userHandler.RemoveApiKey)
		ru.Get("/credits", userHandler.Credits)
	})

	addr := ":" + cfg.Port
	logger.Info().Str("addr", addr).Msg("BLU IA API Go escuchando")
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatal(err)
	}
}

// keep pgxpool import used when pool is nil path still references it
var _ *pgxpool.Pool
