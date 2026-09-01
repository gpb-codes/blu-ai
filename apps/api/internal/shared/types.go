// Package shared — contrato de API compartido (port de packages/shared/src/index.ts).
package shared

type PlanID string

const (
	PlanFree    PlanID = "FREE"
	PlanBYOK    PlanID = "BYOK"
	PlanCredits PlanID = "CREDITS"
)

type Role string

const (
	RoleUser  Role = "USER"
	RoleAdmin Role = "ADMIN"
)

type MemberRole string

const (
	MemberOwner  MemberRole = "OWNER"
	MemberAdmin  MemberRole = "ADMIN"
	MemberEditor MemberRole = "EDITOR"
	MemberViewer MemberRole = "VIEWER"
)

type TierID string

const (
	TierLight TierID = "light"
	TierFlash TierID = "flash"
	TierUltra TierID = "ultra"
	TierAuto  TierID = "auto"
)

type ProviderID string

const (
	ProviderAnthropic  ProviderID = "anthropic"
	ProviderOpenAI     ProviderID = "openai"
	ProviderGemini     ProviderID = "gemini"
	ProviderOpenRouter ProviderID = "openrouter"
	ProviderBluFinetune ProviderID = "blu-finetune"
)

type AgentID string

const (
	AgentPlan       AgentID = "plan"
	AgentBuild      AgentID = "build"
	AgentCowork     AgentID = "cowork"
	AgentResearch   AgentID = "research"
	AgentQA         AgentID = "qa"
	AgentAutomation AgentID = "automation"
	AgentKnowledge  AgentID = "knowledge"
)

type ChatRole string

const (
	ChatRoleSystem    ChatRole = "system"
	ChatRoleUser      ChatRole = "user"
	ChatRoleAssistant ChatRole = "assistant"
)

type ChatMessage struct {
	ID         string   `json:"id"`
	Role       ChatRole `json:"role"`
	Content    string   `json:"content"`
	Model      *string  `json:"model,omitempty"`
	AgentID    *AgentID `json:"agentId,omitempty"`
	CreatedAt  string   `json:"createdAt"`
	CitedNotes []string `json:"citedNotes,omitempty"`
}

type UserProfile struct {
	ID           string  `json:"id"`
	Email        *string `json:"email"`
	Phone        *string `json:"phone"`
	GoogleSub    *string `json:"googleSub"`
	DisplayName  string  `json:"displayName"`
	Timezone     string  `json:"timezone"`
	Plan         PlanID  `json:"plan"`
	TosAcceptedAt *string `json:"tosAcceptedAt"`
	Role         Role    `json:"role"`
}

type ProjectSummary struct {
	ID          string     `json:"id"`
	Name        string     `json:"name"`
	Role        MemberRole `json:"role"`
	MemberCount int        `json:"memberCount"`
}

type NoteSummary struct {
	ID           string   `json:"id"`
	Title        string   `json:"title"`
	Tags         []string `json:"tags"`
	UpdatedAt    string   `json:"updatedAt"`
	UpdatedBy    string   `json:"updatedBy"`
	BacklinkCount int     `json:"backlinkCount"`
}

type ApiKeyMasked struct {
	ID        string     `json:"id"`
	Provider  ProviderID `json:"provider"`
	MaskedKey string     `json:"maskedKey"`
	CreatedAt string     `json:"createdAt"`
}

type CreditBalance struct {
	Plan     PlanID           `json:"plan"`
	Credits  int              `json:"credits"`
	SoftCaps map[string]int   `json:"softCaps"`
	Frozen   bool             `json:"frozen"`
	ResetsAt *string          `json:"resetsAt"`
}

type AuthTokens struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
}

type SendMessageRequest struct {
	ProjectID *string  `json:"projectId,omitempty"`
	AgentID   *AgentID `json:"agentId,omitempty"`
	Tier      *string  `json:"tier,omitempty"`
	Messages  []ChatMessage `json:"messages"`
}

type SendMessageResponse struct {
	Message    ChatMessage `json:"message"`
	UsedModel  string      `json:"usedModel"`
	CitedNotes []string    `json:"citedNotes"`
}
