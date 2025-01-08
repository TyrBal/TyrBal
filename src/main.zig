const std = @import("std");

// define token types
const TokenType = enum {
    Include,
    Define,
    Function,
    Identifier,
    Number,
    String,
    Operator,
    Punctuation,
    Comment,
    Keyword,
    EndOfFile,
};

const Token = struct {
    type: TokenType,
    lexeme: []const u8,
    line: usize,
};

const Lexer = struct {
    source: []const u8, // entire source code as a string
    start: usize = 0, // starting index of the current token in the source code
    current: usize = 0, // current position in the source code being scanned
    line: usize = 1, // current line number in the source code

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

    // scans an identifier
    fn identifier(self: *Lexer) Token {
        while (std.ascii.isAlphabetic(self.lookAHead()) or self.lookAHead() == '_') {
            _ = self.advance();
        }
        const text = self.source[self.start..self.current];
        const token_type = blk: {
            if (std.mem.eql(u8, text, "include")) break :blk TokenType.Include;
            if (std.mem.eql(u8, text, "define")) break :blk TokenType.Define;
            if (std.mem.eql(u8, text, "function")) break :blk TokenType.Function;
            if (std.mem.eql(u8, text, "if") or
                std.mem.eql(u8, text, "elseif") or
                std.mem.eql(u8, text, "else") or
                std.mem.eql(u8, text, "while") or
                std.mem.eql(u8, text, "for"))
            {
                break :blk TokenType.Keyword;
            }
            break :blk TokenType.Identifier;
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
            .type = TokenType.Number,
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
            std.debug.print("Unterminated string at line {}\n", .{self.line});
            return Token{
                .type = TokenType.EndOfFile,
                .lexeme = "",
                .line = self.line,
            };
        }
        _ = self.advance(); // Closing "
        return Token{
            .type = TokenType.String,
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
                .type = TokenType.EndOfFile,
                .lexeme = "",
                .line = self.line,
            };
        }

        const c = self.advance();
        if (std.ascii.isAlphabetic(c)) return self.identifier();
        if (std.ascii.isDigit(c)) return self.number();

        switch (c) {
            '(' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            ')' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '{' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '}' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '[' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            ']' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '=' => return Token{
                .type = TokenType.Operator,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '<' => return Token{
                .type = TokenType.Operator,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '>' => return Token{
                .type = TokenType.Operator,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '+' => return Token{
                .type = TokenType.Operator,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '-' => return Token{
                .type = TokenType.Operator,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '*' => return Token{
                .type = TokenType.Operator,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '/' => {
                if (self.match('/')) {
                    while (self.lookAHead() != '\n' and !self.isAtEnd()) {
                        _ = self.advance();
                    }
                    return Token{
                        .type = TokenType.Comment,
                        .lexeme = self.source[self.start..self.current],
                        .line = self.line,
                    };
                } else {
                    return Token{
                        .type = TokenType.Operator,
                        .lexeme = self.source[self.start..self.current],
                        .line = self.line,
                    };
                }
            },
            ';' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            ',' => return Token{
                .type = TokenType.Punctuation,
                .lexeme = self.source[self.start..self.current],
                .line = self.line,
            },
            '"' => return self.string(),
            else => {
                std.debug.print("Unexpected character: {c} at line {}\n", .{ c, self.line });
                return Token{
                    .type = TokenType.EndOfFile,
                    .lexeme = "",
                    .line = self.line,
                };
            },
        }
    }
};

// function to convert ASCII to binary
fn asciiToBinary(ascii: u8) [8]u8 {
    var binary: [8]u8 = undefined;
    var value = ascii;
    for (0..8) |i| {
        binary[7 - i] = @as(u8, @truncate(value % 2));
        value /= 2;
    }
    return binary;
}

pub fn main() !void {
    const source_code =
        \\include file_name;
        \\define function_name(argument1, argument2){
        \\    return argument1 - argument2;
        \\}
        \\variable_name = value;
        \\pointer_name = *variable_name;
        \\list_name = [5];
        \\list_name[0] = value;
        \\for (i = 1; i>10; i++){} 
        \\while(bolle==true){} 
        \\if(){}
        \\elseif(){} 
        \\else{}
        \\//comment line
    ;

    var lexer = Lexer.init(source_code);

    const file = try std.fs.cwd().createFile(
        "binary",
        .{ .read = true },
    );
    defer file.close();

    while (!lexer.isAtEnd()) {
        const token = lexer.scanToken();
        std.debug.print("{}\n", .{token});

        // convert each character in token.lexeme to binary and write to file
        // TODO Endre fra .lexeme til å iterere over char fra token.type
        for (token.lexeme) |char| {
            const binary = asciiToBinary(char);
            try file.writeAll(&binary);
        }
    }
}
