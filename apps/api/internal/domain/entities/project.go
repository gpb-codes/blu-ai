package entities

import "time"

type Project struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Slug      string    `json:"slug"`
	OwnerID   string    `json:"ownerId"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

type ProjectMember struct {
	Role      string    `json:"role"`
	User      *User     `json:"user"`
	UserID    string    `json:"userId"`
	CreatedAt time.Time `json:"createdAt"`
}
