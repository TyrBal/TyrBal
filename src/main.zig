const std = @import("std");

<<<<<<< Updated upstream
// TODO operators combine into one token if after another eg:  '+=', '>=' or '!='

// define token types
const TokenType = enum {
=======
// token types
pub const TokenType = enum {
>>>>>>> Stashed changes
    i, //identifier
    k, //keyword
    s, //separator
    o, //operator
    l, //literal
    c, //comment
    e, //eof
    pub fn toString(self: TokenType) []const u8 {
        return @tagName(self);
    }
};

const Token = struct {
    type: TokenType,
    lexeme: []const u8,
    line: usize,
};

const Lexer = struct {
    source: []const u8, // entire source code as a string
    start: usize = 0, // starting index of the current token
    current: usize = 0, // current position in the source code being scanned
    line: usize = 1, // current line number

    fn init(source: []const u8) Lexer {
        return Lexer{
            .source = source,
        };
    }

    // checks if the lexer has reached the end of the source code
    fn isAtEnd(self: *Lexer) bool {
        return self.current >= self.source.len;
    }

    // moves the current pointer forward by one character and returns the character
    fn advance(self: *Lexer) u8 {
        self.current += 1;
        return self.source[self.current - 1];
    }

    // looks at the current character without consuming it
    fn lookAHead(self: *Lexer) u8 {
        if (self.isAtEnd()) return 0;
        return self.source[self.current];
    }

    // checks if the current character matches an expected character and consumes it if it does
    fn match(self: *Lexer, expected: u8) bool {
        if (self.isAtEnd()) return false;
        if (self.source[self.current] != expected) return false;
        self.current += 1;
        return true;
    }

    // skips over whitespace characters
    fn skipWhitespace(self: *Lexer) void {
        while (!self.isAtEnd()) {
            const c = self.lookAHead();
            switch (c) {
                ' ', '\r', '\t' => {
                    _ = self.advance();
                },
                '\n' => {
                    self.line += 1;
                    _ = self.advance();
                },
                else => break,
            }
        }
    }

    // scans an identifier or keyword
    fn identifier(self: *Lexer) Token {
        while (std.ascii.isAlphanumeric(self.lookAHead()) or self.lookAHead() == '_' or self.lookAHead() == '.') {
            _ = self.advance();
        }
        const text = self.source[self.start..self.current];
        const token_type = blk: {
            if (std.mem.eql(u8, text, "include") or
                std.mem.eql(u8, text, "define") or
                std.mem.eql(u8, text, "function") or
                std.mem.eql(u8, text, "if") or
                std.mem.eql(u8, text, "elseif") or
                std.mem.eql(u8, text, "else") or
                std.mem.eql(u8, text, "while") or
                std.mem.eql(u8, text, "for") or
                std.mem.eql(u8, text, "return"))
            {
                break :blk TokenType.k;
            }
            break :blk TokenType.i;
        };
        return Token{
            .type = token_type,
            .lexeme = text,
            .line = self.line,
        };
    }

    // scans a numeric literal
    fn number(self: *Lexer) Token {
        while (std.ascii.isDigit(self.lookAHead())) {
            _ = self.advance();
        }
        return Token{
            .type = TokenType.l,
            .lexeme = self.source[self.start..self.current],
            .line = self.line,
        };
    }

    // scans a string literal
    fn string(self: *Lexer) Token {
        while (self.lookAHead() != '"' and !self.isAtEnd()) {
            if (self.lookAHead() == '\n') self.line += 1;
            _ = self.advance();
        }
        if (self.isAtEnd()) {
            return Token{
                .type = TokenType.e,
                .lexeme = "",
                .line = self.line,
            };
        }
        _ = self.advance(); // closing "
        return Token{
            .type = TokenType.l,
            .lexeme = self.source[self.start + 1 .. self.current - 1],
            .line = self.line,
        };
    }

    // scans the next token in the source code
    fn scanToken(self: *Lexer) Token {
        self.skipWhitespace();
        self.start = self.current;

        if (self.isAtEnd()) {
            return Token{
                .type = TokenType.e,
                .lexeme = "",
                .line = self.line,
            };
        }

        const c = self.advance();
        if (std.ascii.isAlphabetic(c)) return self.identifier();
        if (std.ascii.isDigit(c)) return self.number();

        switch (c) {
            '(', ')', '{', '}', '[', ']', ';', ',' => return Token{
                .type = TokenType.s,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '=', '<', '>', '+', '-', '*', '/', '!' => {
                if (c == '/' and self.match('/')) {
                    while (self.lookAHead() != '\n' and !self.isAtEnd()) {
                        _ = self.advance();
                    }
                    return Token{
                        .type = TokenType.c,
                        .lexeme = self.source[self.start..self.current],
                        .line = self.line,
                    };
                } else {
                    return Token{
                        .type = TokenType.o,
                        .lexeme = self.source[self.start..self.current],
                        .line = self.line,
                    };
                }
            },
            '"' => return self.string(),
            else => {
                std.debug.print("Unexpected character: {c} at line {}\n", .{ c, self.line });
                return Token{
                    .type = TokenType.e,
                    .lexeme = "",
                    .line = self.line,
                };
            },
        }
    }

    fn writeToken(token: Token, writer: anytype) !void {
        const type_string = token.type.toString();
        try writer.print("{s}({s})", .{ type_string, token.lexeme });
    }
};

pub fn main() !void {
    // get the allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // get the command-line arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // the filename is the second argument
    const filename = args[1];

    // open the input file and read its contents
    const input_file = try std.fs.cwd().openFile(filename, .{});
    defer input_file.close();
    const source = try input_file.readToEndAlloc(allocator, std.math.maxInt(usize));

    var lexer = Lexer.init(source);

    const file = try std.fs.cwd().createFile(
        "tokens",
        .{},
    );
    defer file.close();
    const writer = file.writer();

    while (!lexer.isAtEnd()) {
        const token = lexer.scanToken();
        try Lexer.writeToken(token, writer);
        if (!lexer.isAtEnd()) {
            try writer.writeAll("  ");
        }
    }
}
