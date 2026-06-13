; extends
(assignment
  left: (identifier) @_id
  (#match? @_id "sql")
  right: (string (string_content) @injection.content)
  (#set! injection.language "sql"))
(default_parameter
  name: (identifier) @_id
  (#match? @_id "sql")
  value: (string (string_content) @injection.content)
  (#set! injection.language "sql"))
(keyword_argument
  name: (identifier) @_id
  (#match? @_id "sql")
  value: (string (string_content) @injection.content)
  (#set! injection.language "sql"))
