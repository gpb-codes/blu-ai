package memory

import "strings"

func ExtractWikilinks(bodyMd string) []string {
	var titles []string
	matches := WikilinkRE.FindAllStringSubmatch(bodyMd, -1)
	for _, m := range matches {
		if len(m) < 2 {
			continue
		}
		title := strings.TrimSpace(m[1])
		if title != "" {
			titles = append(titles, title)
		}
	}
	return titles
}

func BuildLinks(notes []Note) []NoteLink {
	byTitle := make(map[string]string, len(notes))
	for _, n := range notes {
		byTitle[strings.ToLower(n.Title)] = n.ID
	}
	var links []NoteLink
	for _, n := range notes {
		for _, title := range ExtractWikilinks(n.BodyMd) {
			targetID, ok := byTitle[strings.ToLower(title)]
			if ok && targetID != n.ID {
				links = append(links, NoteLink{SourceNoteID: n.ID, TargetNoteID: targetID})
			}
		}
	}
	return links
}

func Backlinks(noteID string, links []NoteLink) []NoteLink {
	var out []NoteLink
	for _, l := range links {
		if l.TargetNoteID == noteID {
			out = append(out, l)
		}
	}
	return out
}

func Neighbors(noteID string, links []NoteLink) []string {
	set := make(map[string]struct{})
	for _, l := range links {
		if l.SourceNoteID == noteID {
			set[l.TargetNoteID] = struct{}{}
		}
		if l.TargetNoteID == noteID {
			set[l.SourceNoteID] = struct{}{}
		}
	}
	out := make([]string, 0, len(set))
	for k := range set {
		out = append(out, k)
	}
	return out
}

func BuildGraph(notes []Note, links []NoteLink) KnowledgeGraph {
	byID := make(map[string]Note, len(notes))
	for _, n := range notes {
		byID[n.ID] = n
	}
	nodes := make([]GraphNode, 0, len(notes))
	for _, n := range notes {
		nodes = append(nodes, GraphNode{ID: n.ID, Title: n.Title, Tags: n.Tags})
	}
	var edges []GraphEdge
	for _, l := range links {
		if _, ok := byID[l.SourceNoteID]; !ok {
			continue
		}
		if _, ok := byID[l.TargetNoteID]; !ok {
			continue
		}
		edges = append(edges, GraphEdge{Source: l.SourceNoteID, Target: l.TargetNoteID})
	}
	if edges == nil {
		edges = []GraphEdge{}
	}
	return KnowledgeGraph{Nodes: nodes, Edges: edges}
}
