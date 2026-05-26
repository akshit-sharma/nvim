; inherits: none

;; Fold function bodies but keep the 'function name(args)' visible
(function_definition (block) @fold)

;; Fold table content (multi-line tables) but keep the variable name visible
(table_constructor) @fold

;; Control structures: Fold the block inside, keeping 'if/for/while' visible
(if_statement (block) @fold)
(for_statement (block) @fold)
(while_statement (block) @fold)
(repeat_statement (block) @fold)

;; Fold the explicit 'do ... end' blocks
(do_statement (block) @fold)

;; Group consecutive comments (Docstrings/Headers)
((comment)+ @fold)
