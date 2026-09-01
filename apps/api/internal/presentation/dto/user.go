package dto

import "github.com/blu-ia/api/internal/shared"

type UpdateProfileRequest struct {
	DisplayName *string `json:"displayName"`
	Timezone    *string `json:"timezone"`
}

type AddApiKeyRequest struct {
	Provider shared.ProviderID `json:"provider"`
	Key      string            `json:"key"`
}
