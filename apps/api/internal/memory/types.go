package memory

import (
	"regexp"
	"time"
)

type NoteSource string

const (
	SourceChat   NoteSource = "chat"
	SourceManual NoteSource = "manual"
	SourceAgent  NoteSource = "agent"
	SourceImport NoteSource = "import"
)

type Note struct {
	ID        string     `json:"id"`
	ProjectID string     `json:"projectId"`
	Title     string     `json:"title"`
	BodyMd    string     `json:"bodyMd"`
	Tags      []string   `json:"tags"`
	Source    NoteSource `json:"source"`
	CreatedBy string     `json:"createdBy"`
	UpdatedBy string     `json:"updatedBy"`
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt"`
}

type NoteLink struct {
	SourceNoteID string  `json:"sourceNoteId"`
	TargetNoteID string  `json:"targetNoteId"`
	Label        *string `json:"label"`
}

type NoteChunk struct {
	NoteID    string    `json:"noteId"`
	Index     int       `json:"index"`
	Text      string    `json:"text"`
	Embedding []float32 `json:"embedding,omitempty"`
}

type NoteVersion struct {
	NoteID   string    `json:"noteId"`
	Version  int       `json:"version"`
	BodyMd   string    `json:"bodyMd"`
	EditedBy string    `json:"editedBy"`
	EditedAt time.Time `json:"editedAt"`
}

type GraphNode struct {
	ID     string   `json:"id"`
	Title  string   `json:"title"`
	Tags   []string `json:"tags"`
	Folder *string  `json:"folder"`
}

type GraphEdge struct {
	Source string `json:"source"`
	Target string `json:"target"`
}

type KnowledgeGraph struct {
	Nodes []GraphNode `json:"nodes"`
	Edges []GraphEdge `json:"edges"`
}

var WikilinkRE = regexp.MustCompile(`\[\[([^\]|]+)(?:\|([^\]]+))?\]\]`)
