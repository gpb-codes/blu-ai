package auth

import "golang.org/x/crypto/bcrypt"

// BcryptHasher — reemplazo de Argon2PasswordHasher (apps/api/src/infrastructure/auth/password-argon2.service.ts:8)
// Argon2 puro requiere CGO; bcrypt es estándar sin CGO y cumple el contrato PasswordHasher.
// Para argon2id real: cambiar a github.com/matthewhartstonge/argon2.
type BcryptHasher struct{}

func (h *BcryptHasher) Hash(plain string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hash), nil
}

func (h *BcryptHasher) Verify(hash, plain string) (bool, error) {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(plain))
	if err == bcrypt.ErrMismatchedHashAndPassword {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return true, nil
}
