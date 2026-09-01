package entities

import (
	"time"

	"github.com/blu-ia/api/internal/shared"
)

type User struct {
	ID            string           `json:"id"`
	Email         *string          `json:"email"`
	Phone         *string          `json:"phone"`
	DisplayName   string           `json:"displayName"`
	Timezone      string           `json:"timezone"`
	Plan          shared.PlanID    `json:"plan"`
	Role          shared.Role      `json:"role"`
	TosAcceptedAt *time.Time       `json:"tosAcceptedAt"`
	PasswordHash  *string          `json:"-"`
}
