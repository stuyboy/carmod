package model

//The full response.  What search term was, and what was matched.
type SearchResponse struct {
	SearchTerm string
	Mods       []SearchResult
}

type SearchResult interface {
	Name() string
}
