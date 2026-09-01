// Contexto de autenticación: restaura la sesión al cargar, expone login/register/logout
// y refresca los tokens en segundo plano cuando expiran.

"use client";

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { authApi, sessionStorage } from "@/lib/api";
import type { UserProfile } from "@/types";

type AuthStatus = "loading" | "authenticated" | "unauthenticated";

interface AuthContextValue {
  status: AuthStatus;
  user: UserProfile | null;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string, displayName: string) => Promise<void>;
  logout: () => Promise<void>;
  updateUser: (user: UserProfile) => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [status, setStatus] = useState<AuthStatus>("loading");
  const [user, setUser] = useState<UserProfile | null>(null);

  const applyAuth = useCallback((result: { user: UserProfile; accessToken: string; refreshToken: string }) => {
    sessionStorage.setTokens(result.accessToken, result.refreshToken);
    setUser(result.user);
    setStatus("authenticated");
  }, []);

  useEffect(() => {
    const restore = async () => {
      if (!sessionStorage.accessToken || !sessionStorage.refreshToken) {
        setStatus("unauthenticated");
        return;
      }
      try {
        setUser(await authApi.me());
        setStatus("authenticated");
      } catch {
        // el 401 ya disparó el refresh automático; si sigue fallando, se limpia la sesión
        setUser(null);
        setStatus("unauthenticated");
      }
    };
    void restore();
  }, []);

  const login = useCallback(
    async (email: string, password: string) => {
      applyAuth(await authApi.login(email, password));
    },
    [applyAuth],
  );

  const register = useCallback(
    async (email: string, password: string, displayName: string) => {
      applyAuth(await authApi.register(email, password, displayName));
    },
    [applyAuth],
  );

  const logout = useCallback(async () => {
    const refreshToken = sessionStorage.refreshToken;
    if (refreshToken) {
      try {
        await authApi.logout(refreshToken);
      } catch {
        // si el servidor no responde, igual se limpia la sesión local
      }
    }
    sessionStorage.clear();
    setUser(null);
    setStatus("unauthenticated");
  }, []);

  const updateUser = useCallback((updated: UserProfile) => setUser(updated), []);

  const value = useMemo(
    () => ({ status, user, login, register, logout, updateUser }),
    [status, user, login, register, logout, updateUser],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth debe usarse dentro de <AuthProvider>");
  return ctx;
}