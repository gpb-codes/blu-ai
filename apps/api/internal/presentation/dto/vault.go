package dto

import "strings"

type CreateNoteRequest struct {
	ProjectID string   `json:"projectId"`
	Title     string   `json:"title"`
	BodyMd    string   `json:"bodyMd"`
	Tags      []string `json:"tags"`
}

func (r CreateNoteRequest) Validate() []string {
	if r.ProjectID == "" {
		return []string{"projectId requerido"}
	}
	if strings.TrimSpace(r.Title) == "" {
		return []string{"title requerido"}
	}
	if len(r.Title) > 120 {
		return []string{"title máximo 120"}
	}
	return nil
}

type UpdateNoteRequest struct {
	Title  *string  `json:"title"`
	BodyMd *string  `json:"bodyMd"`
	Tags   []string `json:"tags"`
	HasTags bool    `json:"-"`
}
