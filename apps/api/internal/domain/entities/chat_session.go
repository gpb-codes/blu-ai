package entities

import "time"

type ChatSession struct {
	ID        string     `json:"id"`
	ProjectID *string    `json:"projectId"`
	UserID    string     `json:"userId"`
	AgentID   *string    `json:"agentId"`
	Title     string     `json:"title"`
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
}
