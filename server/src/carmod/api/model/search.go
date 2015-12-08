package model

//The full response.  What search term was, and what was matched.
type SearchResponse struct {
	SearchTerm 	  string          `json:"searchTerm"`
	Results       []SearchResult  `json:"results"`
}

type SearchResult interface {
	Name() string
}