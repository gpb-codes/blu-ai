package auth

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"io"
	"os"
)

// ApiKeyCipher — port de api-key-cipher.service.ts: AES-256-GCM con clave derivada de API_KEY_CIPHER_SECRET.
// Si la secret no está seteada, usa JWT_SECRET como fallback (mismo comportamiento dev).
type ApiKeyCipher struct {
	key []byte
}

func NewApiKeyCipher() *ApiKeyCipher {
	secret := os.Getenv("API_KEY_CIPHER_SECRET")
	if secret == "" {
		secret = os.Getenv("JWT_SECRET")
		if secret == "" {
			secret = "dev-cipher-secret-32-bytes-long!!"
		}
	}
	h := sha256.Sum256([]byte(secret))
	return &ApiKeyCipher{key: h[:]}
}

func (c *ApiKeyCipher) Encrypt(plain string) string {
	block, err := aes.NewCipher(c.key)
	if err != nil {
		panic(err)
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		panic(err)
	}
	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		panic(err)
	}
	ct := gcm.Seal(nonce, nonce, []byte(plain), nil)
	return base64.RawStdEncoding.EncodeToString(ct)
}

func (c *ApiKeyCipher) Decrypt(enc string) (string, error) {
	raw, err := base64.RawStdEncoding.DecodeString(enc)
	if err != nil {
		return "", fmt.Errorf("cipher decode: %w", err)
	}
	block, err := aes.NewCipher(c.key)
	if err != nil {
		return "", err
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}
	nonceSize := gcm.NonceSize()
	if len(raw) < nonceSize {
		return "", fmt.Errorf("ciphertext too short")
	}
	nonce, ct := raw[:nonceSize], raw[nonceSize:]
	pt, err := gcm.Open(nil, nonce, ct, nil)
	if err != nil {
		return "", fmt.Errorf("decrypt: %w", err)
	}
	return string(pt), nil
}

func (c *ApiKeyCipher) Mask(plain string) string {
	if len(plain) <= 8 {
		return "sk-...****"
	}
	return plain[:4] + "..." + plain[len(plain)-4:]
}
