const std = @import("std");
const testing = std.testing;

// Import the types and functions from main.zig
const main = @import("main.zig");
const TokenType = main.TokenType;
const Token = main.Token;
const Lexer = main.Lexer;

test "TokenType toString" {
    try testing.expectEqualStrings("i", TokenType.i.toString());
    try testing.expectEqualStrings("k", TokenType.k.toString());
    try testing.expectEqualStrings("s", TokenType.s.toString());
    try testing.expectEqualStrings("o", TokenType.o.toString());
    try testing.expectEqualStrings("l", TokenType.l.toString());
    try testing.expectEqualStrings("c", TokenType.c.toString());
    try testing.expectEqualStrings("e", TokenType.e.toString());
}

test "Lexer initialization" {
    const source = "test source";
    const lexer = Lexer.init(source);

    try testing.expectEqual(@as(usize, 0), lexer.start);
    try testing.expectEqual(@as(usize, 0), lexer.current);
    try testing.expectEqual(@as(usize, 1), lexer.line);
    try testing.expectEqualStrings(source, lexer.source);
}

test "Lexer isAtEnd" {
    const source = "ab";
    var lexer = Lexer.init(source);

    try testing.expect(!lexer.isAtEnd());
    lexer.current = 1;
    try testing.expect(!lexer.isAtEnd());
    lexer.current = 2;
    try testing.expect(lexer.isAtEnd());
    lexer.current = 3;
    try testing.expect(lexer.isAtEnd());
}

test "Lexer advance" {
    const source = "abc";
    var lexer = Lexer.init(source);

    try testing.expectEqual(@as(u8, 'a'), lexer.advance());
    try testing.expectEqual(@as(usize, 1), lexer.current);

    try testing.expectEqual(@as(u8, 'b'), lexer.advance());
    try testing.expectEqual(@as(usize, 2), lexer.current);
}

test "Lexer lookAHead" {
    const source = "abc";
    var lexer = Lexer.init(source);

    try testing.expectEqual(@as(u8, 'a'), lexer.lookAHead());
    try testing.expectEqual(@as(usize, 0), lexer.current); // Should not advance

    lexer.current = 2;
    try testing.expectEqual(@as(u8, 'c'), lexer.lookAHead());

    lexer.current = 3;
    try testing.expectEqual(@as(u8, 0), lexer.lookAHead()); // At end
}

test "Lexer match" {
    const source = "abc";
    var lexer = Lexer.init(source);

    try testing.expect(lexer.match('a'));
    try testing.expectEqual(@as(usize, 1), lexer.current);

    try testing.expect(!lexer.match('c')); // Should be 'b' now
    try testing.expectEqual(@as(usize, 1), lexer.current); // Should not advance

    try testing.expect(lexer.match('b'));
    try testing.expectEqual(@as(usize, 2), lexer.current);
}

test "Lexer skipWhitespace" {
    const source = "  \t\n  hello";
    var lexer = Lexer.init(source);

    lexer.skipWhitespace();
    try testing.expectEqual(@as(usize, 6), lexer.current);
    try testing.expectEqual(@as(usize, 2), lexer.line); // Should increment for \n
}

test "scan identifier tokens" {
    const source = "hello world123 test_var";
    var lexer = Lexer.init(source);

    const token1 = lexer.scanToken();
    try testing.expectEqual(TokenType.i, token1.type);
    try testing.expectEqualStrings("hello", token1.lexeme);
    try testing.expectEqual(@as(usize, 1), token1.line);

    const token2 = lexer.scanToken();
    try testing.expectEqual(TokenType.i, token2.type);
    try testing.expectEqualStrings("world123", token2.lexeme);

    const token3 = lexer.scanToken();
    try testing.expectEqual(TokenType.i, token3.type);
    try testing.expectEqualStrings("test_var", token3.lexeme);
}

test "scan keyword tokens" {
    const keywords = [_][]const u8{ "include", "define", "function", "if", "elseif", "else", "while", "for", "return" };

    for (keywords) |keyword| {
        var lexer = Lexer.init(keyword);
        const token = lexer.scanToken();
        try testing.expectEqual(TokenType.k, token.type);
        try testing.expectEqualStrings(keyword, token.lexeme);
    }
}

test "scan number tokens" {
    const source = "123 456 0 999";
    var lexer = Lexer.init(source);

    const token1 = lexer.scanToken();
    try testing.expectEqual(TokenType.l, token1.type);
    try testing.expectEqualStrings("123", token1.lexeme);

    const token2 = lexer.scanToken();
    try testing.expectEqual(TokenType.l, token2.type);
    try testing.expectEqualStrings("456", token2.lexeme);

    const token3 = lexer.scanToken();
    try testing.expectEqual(TokenType.l, token3.type);
    try testing.expectEqualStrings("0", token3.lexeme);
}

test "scan string tokens" {
    const source = "\"hello world\" \"test\"";
    var lexer = Lexer.init(source);

    const token1 = lexer.scanToken();
    try testing.expectEqual(TokenType.l, token1.type);
    try testing.expectEqualStrings("hello world", token1.lexeme);

    const token2 = lexer.scanToken();
    try testing.expectEqual(TokenType.l, token2.type);
    try testing.expectEqualStrings("test", token2.lexeme);
}

test "scan unterminated string" {
    const source = "\"unterminated";
    var lexer = Lexer.init(source);

    const token = lexer.scanToken();
    try testing.expectEqual(TokenType.e, token.type);
}

test "scan separator tokens" {
    const source = "(){}[];,";
    var lexer = Lexer.init(source);

    const separators = [_][]const u8{ "(", ")", "{", "}", "[", "]", ";", "," };

    for (separators) |sep| {
        const token = lexer.scanToken();
        try testing.expectEqual(TokenType.s, token.type);
        try testing.expectEqualStrings(sep, token.lexeme);
    }
}

test "scan operator tokens" {
    const source = "= == < > + - * / ! != <= >= +=";
    var lexer = Lexer.init(source);

    const operators = [_][]const u8{ "=", "==", "<", ">", "+", "-", "*", "/", "!", "!=", "<=", ">=", "+=" };

    for (operators) |op| {
        const token = lexer.scanToken();
        try testing.expectEqual(TokenType.o, token.type);
        try testing.expectEqualStrings(op, token.lexeme);
    }
}

test "scan line comment" {
    const source = "// this is a comment\nhello";
    var lexer = Lexer.init(source);

    const token1 = lexer.scanToken();
    try testing.expectEqual(TokenType.c, token1.type);
    try testing.expectEqualStrings("// this is a comment", token1.lexeme);

    const token2 = lexer.scanToken();
    try testing.expectEqual(TokenType.i, token2.type);
    try testing.expectEqualStrings("hello", token2.lexeme);
}

test "scan EOF token" {
    const source = "";
    var lexer = Lexer.init(source);

    const token = lexer.scanToken();
    try testing.expectEqual(TokenType.e, token.type);
    try testing.expectEqualStrings("", token.lexeme);
}

test "line counting" {
    const source = "hello\nworld\n\ntest";
    var lexer = Lexer.init(source);

    const token1 = lexer.scanToken();
    try testing.expectEqual(@as(usize, 1), token1.line);

    const token2 = lexer.scanToken();
    try testing.expectEqual(@as(usize, 2), token2.line);

    const token3 = lexer.scanToken();
    try testing.expectEqual(@as(usize, 4), token3.line);
}

test "complex expression tokenization" {
    const source = "if(x == 42) { return x + 1; }";
    var lexer = Lexer.init(source);

    const expected_tokens = [_]struct { type: TokenType, lexeme: []const u8 }{
        .{ .type = TokenType.k, .lexeme = "if" },
        .{ .type = TokenType.s, .lexeme = "(" },
        .{ .type = TokenType.i, .lexeme = "x" },
        .{ .type = TokenType.o, .lexeme = "==" },
        .{ .type = TokenType.l, .lexeme = "42" },
        .{ .type = TokenType.s, .lexeme = ")" },
        .{ .type = TokenType.s, .lexeme = "{" },
        .{ .type = TokenType.k, .lexeme = "return" },
        .{ .type = TokenType.i, .lexeme = "x" },
        .{ .type = TokenType.o, .lexeme = "+" },
        .{ .type = TokenType.l, .lexeme = "1" },
        .{ .type = TokenType.s, .lexeme = ";" },
        .{ .type = TokenType.s, .lexeme = "}" },
    };

    for (expected_tokens) |expected| {
        const token = lexer.scanToken();
        try testing.expectEqual(expected.type, token.type);
        try testing.expectEqualStrings(expected.lexeme, token.lexeme);
    }

    // Should be at end now
    const eof_token = lexer.scanToken();
    try testing.expectEqual(TokenType.e, eof_token.type);
}

test "identifier with dots" {
    const source = "first_saga.tb module.function";
    var lexer = Lexer.init(source);

    const token1 = lexer.scanToken();
    try testing.expectEqual(TokenType.i, token1.type);
    try testing.expectEqualStrings("first_saga.tb", token1.lexeme);

    const token2 = lexer.scanToken();
    try testing.expectEqual(TokenType.i, token2.type);
    try testing.expectEqualStrings("module.function", token2.lexeme);
}

test "hex literal recognition" {
    const source = "0xF 0x123 xF";
    var lexer = Lexer.init(source);

    const token1 = lexer.scanToken();
    try testing.expectEqual(TokenType.l, token1.type);
    try testing.expectEqualStrings("0", token1.lexeme);

    const token2 = lexer.scanToken();
    try testing.expectEqual(TokenType.i, token2.type);
    try testing.expectEqualStrings("xF", token2.lexeme);
}

test "full pseudo syntax sample" {
    const source =
        \\define subtracting(number1,number2){
        \\    return number1 - number2 ;
        \\}
    ;
    var lexer = Lexer.init(source);

    const expected_tokens = [_]struct { type: TokenType, lexeme: []const u8 }{
        .{ .type = TokenType.k, .lexeme = "define" },
        .{ .type = TokenType.i, .lexeme = "subtracting" },
        .{ .type = TokenType.s, .lexeme = "(" },
        .{ .type = TokenType.i, .lexeme = "number1" },
        .{ .type = TokenType.s, .lexeme = "," },
        .{ .type = TokenType.i, .lexeme = "number2" },
        .{ .type = TokenType.s, .lexeme = ")" },
        .{ .type = TokenType.s, .lexeme = "{" },
        .{ .type = TokenType.k, .lexeme = "return" },
        .{ .type = TokenType.i, .lexeme = "number1" },
        .{ .type = TokenType.o, .lexeme = "-" },
        .{ .type = TokenType.i, .lexeme = "number2" },
        .{ .type = TokenType.s, .lexeme = ";" },
        .{ .type = TokenType.s, .lexeme = "}" },
    };

    for (expected_tokens) |expected| {
        const token = lexer.scanToken();
        try testing.expectEqual(expected.type, token.type);
        try testing.expectEqualStrings(expected.lexeme, token.lexeme);
    }
}
