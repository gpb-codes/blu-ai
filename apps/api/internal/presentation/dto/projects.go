package dto

import "strings"

type CreateProjectRequest struct {
	Name string `json:"name"`
}

func (r CreateProjectRequest) Validate() []string {
	if strings.TrimSpace(r.Name) == "" {
		return []string{"name requerido"}
	}
	if len(r.Name) > 80 {
		return []string{"name máximo 80 caracteres"}
	}
	return nil
}

type UpdateProjectRequest struct {
	Name *string `json:"name"`
}

type AddMemberRequest struct {
	UserID string `json:"userId"`
	Role   string `json:"role"`
}

func (r AddMemberRequest) Validate() []string {
	if r.UserID == "" {
		return []string{"userId requerido"}
	}
	if r.Role != "OWNER" && r.Role != "ADMIN" && r.Role != "EDITOR" && r.Role != "VIEWER" {
		return []string{"role inválido"}
	}
	return nil
}

type UpdateMemberRoleRequest struct {
	Role string `json:"role"`
}
