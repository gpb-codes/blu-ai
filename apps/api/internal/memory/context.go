package memory

import (
	"fmt"
	"strings"
)

type ContextOptions struct {
	RelevantNotes     []Note
	Links             []NoteLink
	CitedTitles       []string
	MaxNotes          int
	IncludeGraphTrail *bool
}

type MemoryContext struct {
	Notes []Note  `json:"notes"`
	Trail []string `json:"trail"`
	Text  string  `json:"text"`
}

func BuildMemoryContext(opts ContextOptions) MemoryContext {
	max := opts.MaxNotes
	if max == 0 {
		max = 5
	}
	includeTrail := true
	if opts.IncludeGraphTrail != nil {
		includeTrail = *opts.IncludeGraphTrail
	}
	byTitle := make(map[string]Note, len(opts.RelevantNotes))
	for _, n := range opts.RelevantNotes {
		byTitle[strings.ToLower(n.Title)] = n
	}
	byID := make(map[string]Note, len(opts.RelevantNotes))
	for _, n := range opts.RelevantNotes {
		byID[n.ID] = n
	}
	var selected []Note
	seen := make(map[string]struct{})
	for _, n := range opts.RelevantNotes {
		if _, ok := seen[n.ID]; ok {
			continue
		}
		seen[n.ID] = struct{}{}
		selected = append(selected, n)
		if len(selected) >= max {
			break
		}
	}
	if includeTrail {
		origLen := len(selected)
		for i := 0; i < origLen; i++ {
			n := selected[i]
			for _, nid := range Neighbors(n.ID, opts.Links) {
				if _, ok := seen[nid]; ok {
					continue
				}
				if neighbor, ok := byID[nid]; ok {
					seen[nid] = struct{}{}
					selected = append(selected, neighbor)
					if len(selected) >= max {
						break
					}
				}
			}
			if len(selected) >= max {
				break
			}
		}
	}
	for _, title := range opts.CitedTitles {
		if n, ok := byTitle[strings.ToLower(title)]; ok {
			if _, seen2 := seen[n.ID]; !seen2 {
				seen[n.ID] = struct{}{}
				selected = append(selected, n)
			}
		}
	}
	var sb strings.Builder
	for i, n := range selected {
		if i > 0 {
			sb.WriteString("\n\n---\n\n")
		}
		sb.WriteString(fmt.Sprintf("# %s\n", n.Title))
		if len(n.Tags) > 0 {
			sb.WriteString(fmt.Sprintf("tags: %s\n", strings.Join(n.Tags, ", ")))
		}
		sb.WriteString(n.BodyMd)
	}
	trail := make([]string, 0, len(selected))
	for _, n := range selected {
		trail = append(trail, n.Title)
	}
	return MemoryContext{Notes: selected, Trail: trail, Text: sb.String()}
}
