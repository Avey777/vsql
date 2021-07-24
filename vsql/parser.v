// parser.v creates the AST structure from the tokens generated by lexer.v

module vsql

struct Parser {
	tokens []Token
mut:
	pos int
}

fn parse(sql string) ?Stmt {
	tokens := tokenize(sql)
	mut parser := Parser{tokens, 0}

	match tokens[0].kind {
		.keyword_create {
			return parser.consume_create() or { return err }
		}
		.keyword_delete {
			return parser.consume_delete() or { return err }
		}
		.keyword_drop {
			return parser.consume_drop_table() or { return err }
		}
		.keyword_insert {
			return parser.consume_insert() or { return err }
		}
		.keyword_select {
			return parser.consume_select() or { return err }
		}
		.keyword_update {
			return parser.consume_update() or { return err }
		}
		else {
			return sqlstate_42601('at "${tokens[0].value}"') // syntax error
		}
	}
}

fn (mut p Parser) peek(tks ...TokenKind) []Token {
	mut pos := p.pos
	mut toks := []Token{}

	for tk in tks {
		if p.tokens[pos].kind != tk {
			return []Token{}
		}

		toks << p.tokens[pos]
		pos++
	}

	return toks
}

fn (mut p Parser) consume_type() ?string {
	// These need to be sorted with longest first to avoid consuming an
	// incomplete type.
	types := [
		// 5
		[TokenKind.keyword_char, TokenKind.keyword_varying, TokenKind.op_paren_open,
			TokenKind.literal_number, TokenKind.op_paren_close],
		[TokenKind.keyword_character, TokenKind.keyword_varying, TokenKind.op_paren_open,
			TokenKind.literal_number, TokenKind.op_paren_close],
		// 4
		[TokenKind.keyword_char, TokenKind.op_paren_open, TokenKind.literal_number,
			TokenKind.op_paren_close,
		],
		[TokenKind.keyword_character, TokenKind.op_paren_open, TokenKind.literal_number,
			TokenKind.op_paren_close,
		],
		[TokenKind.keyword_float, TokenKind.op_paren_open, TokenKind.literal_number,
			TokenKind.op_paren_close,
		],
		[TokenKind.keyword_varchar, TokenKind.op_paren_open, TokenKind.literal_number,
			TokenKind.op_paren_close,
		],
		// 2
		[TokenKind.keyword_double, TokenKind.keyword_precision],
		// 1
		[TokenKind.keyword_bigint],
		[TokenKind.keyword_boolean],
		[TokenKind.keyword_character],
		[TokenKind.keyword_char],
		[TokenKind.keyword_float],
		[TokenKind.keyword_integer],
		[TokenKind.keyword_int],
		[TokenKind.keyword_real],
		[TokenKind.keyword_smallint],
	]
	for typ in types {
		peek := p.peek(...typ)
		if peek.len > 0 {
			p.pos += peek.len

			mut s := ''
			for t in peek {
				s += ' ' + t.value
			}

			return s[1..]
		}
	}

	return error('expecting type but found ${p.tokens[p.pos].value}')
}

fn (mut p Parser) consume_create() ?CreateTableStmt {
	// CREATE TABLE <table_name>
	p.consume(TokenKind.keyword_create) ?
	p.consume(TokenKind.keyword_table) ?
	table_name := p.consume(TokenKind.literal_identifier) ?

	// columns
	p.consume(TokenKind.op_paren_open) ?

	mut columns := []Column{}
	col_name := p.consume(TokenKind.literal_identifier) ?
	col_type := p.consume_type() ?
	columns << Column{col_name.value, col_type}

	for p.peek(TokenKind.op_comma).len > 0 {
		p.consume(TokenKind.op_comma) ?
		next_col_name := p.consume(TokenKind.literal_identifier) ?
		next_col_type := p.consume_type() ?
		columns << Column{next_col_name.value, next_col_type}
	}

	p.consume(TokenKind.op_paren_close) ?

	return CreateTableStmt{table_name.value, columns}
}

fn (mut p Parser) consume(tk TokenKind) ?Token {
	if p.tokens[p.pos].kind == tk {
		defer {
			p.pos++
		}

		return p.tokens[p.pos]
	}

	return error('expecting $tk but found ${p.tokens[p.pos].value}')
}

fn (mut p Parser) consume_insert() ?InsertStmt {
	// INSERT INTO <table_name>
	p.consume(TokenKind.keyword_insert) ?
	p.consume(TokenKind.keyword_into) ?
	table_name := p.consume(TokenKind.literal_identifier) ?

	// columns
	p.consume(TokenKind.op_paren_open) ?
	col := p.consume(TokenKind.literal_identifier) ?
	p.consume(TokenKind.op_paren_close) ?

	// values
	p.consume(TokenKind.keyword_values) ?
	p.consume(TokenKind.op_paren_open) ?
	value := p.consume_value() ?
	p.consume(TokenKind.op_paren_close) ?

	return InsertStmt{table_name.value, [col.value], [value]}
}

fn (mut p Parser) consume_select() ?SelectStmt {
	// skip SELECT
	p.pos++

	// fields
	mut fields := new_string_value(p.tokens[p.pos].value)
	if p.tokens[p.pos].kind == TokenKind.literal_number {
		fields = new_f64_value(p.tokens[p.pos].value.f64())
	}
	p.pos++

	// FROM
	mut from := ''
	if p.tokens[p.pos].kind == TokenKind.keyword_from {
		from = p.tokens[p.pos + 1].value
		p.pos += 2
	}

	// WHERE
	mut expr := BinaryExpr{}
	if p.peek(TokenKind.keyword_where).len > 0 {
		expr = p.consume_where() ?
	}

	return SelectStmt{fields, from, expr}
}

fn (mut p Parser) consume_drop_table() ?DropTableStmt {
	// DROP TABLE <table_name>
	p.consume(TokenKind.keyword_drop) ?
	p.consume(TokenKind.keyword_table) ?
	table_name := p.consume(TokenKind.literal_identifier) ?

	return DropTableStmt{table_name.value}
}

fn (mut p Parser) consume_delete() ?DeleteStmt {
	// DELETE FROM <table_name>
	p.consume(TokenKind.keyword_delete) ?
	p.consume(TokenKind.keyword_from) ?
	table_name := p.consume(TokenKind.literal_identifier) ?

	// WHERE
	mut expr := BinaryExpr{}
	if p.peek(TokenKind.keyword_where).len > 0 {
		expr = p.consume_where() ?
	}

	return DeleteStmt{table_name.value, expr}
}

fn (mut p Parser) consume_where() ?BinaryExpr {
	p.consume(TokenKind.keyword_where) ?

	lhs := p.consume(TokenKind.literal_identifier) ?
	mut op := Token{}

	allowed_ops := [
		TokenKind.op_eq,
		TokenKind.op_neq,
		TokenKind.op_gt,
		TokenKind.op_gte,
		TokenKind.op_lt,
		TokenKind.op_lte,
	]
	for allowed_op in allowed_ops {
		if p.peek(allowed_op).len > 0 {
			op = p.consume(allowed_op) ?
			break
		}
	}

	rhs := p.consume_value() ?

	return BinaryExpr{lhs.value, op.value, rhs}
}

fn (mut p Parser) consume_value() ?Value {
	if p.peek(TokenKind.literal_number).len > 0 {
		t := p.consume(TokenKind.literal_number) ?
		return new_f64_value(t.value.f64())
	}

	if p.peek(TokenKind.literal_string).len > 0 {
		t := p.consume(TokenKind.literal_string) ?
		return new_string_value(t.value)
	}

	return error('expecting value but found ${p.tokens[p.pos]}')
}

fn (mut p Parser) consume_update() ?UpdateStmt {
	// UPDATE <table_name>
	p.consume(TokenKind.keyword_update) ?
	table_name := p.consume(TokenKind.literal_identifier) ?

	// SET
	p.consume(TokenKind.keyword_set) ?
	col_name := p.consume(TokenKind.literal_identifier) ?
	p.consume(TokenKind.op_eq) ?
	col_value := p.consume_value() ?
	mut set := map[string]Value{}
	set[col_name.value] = col_value

	// WHERE
	mut expr := BinaryExpr{}
	if p.peek(TokenKind.keyword_where).len > 0 {
		expr = p.consume_where() ?
	}

	return UpdateStmt{table_name.value, set, expr}
}
