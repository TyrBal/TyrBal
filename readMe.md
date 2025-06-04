# Lexical Analyzer for Custom Language

A lexical analyzer (tokenizer) written in Zig that processes source code and breaks it down into tokens for further compilation stages.

## What This Project Actually Does

**THIS IS ONLY A LEXER - NOT A COMPLETE COMPILER**

This project implements **only the first stage** of a compiler - lexical analysis (tokenization). It:

- Reads source code from a file
- Breaks it down into tokens (identifiers, keywords, operators, literals, etc.)
- Outputs the tokens to a file for inspection or further processing
- Provides a foundation for building a complete compiler

**Current Status**:

- ✅ **Lexical Analysis Complete** - Can tokenize source code
- ❌ **Parser Not Implemented** - Cannot build syntax trees
- ❌ **Semantic Analysis Not Implemented** - No type checking
- ❌ **Code Generation Not Implemented** - Cannot produce executable code

**This means**: You can tokenize source code, but you cannot compile it into working programs yet.

## Features

### Token Types Supported

- **Identifiers** (`i`): Variable names, function names (e.g., `variable_name`, `first_saga.tb`)
- **Keywords** (`k`): Language keywords (`include`, `define`, `function`, `if`, `else`, `while`, `for`, `return`)
- **Separators** (`s`): Punctuation (`(`, `)`, `{`, `}`, `[`, `]`, `;`, `,`)
- **Operators** (`o`): Arithmetic and comparison (`+`, `-`, `*`, `/`, `=`, `<`, `>`, `!`)
- **Literals** (`l`): Numbers and strings (`123`, `"hello world"`)
- **Comments** (`c`): Line comments starting with `//`
- **EOF** (`e`): End of file marker

### Language Features Recognized

- Function definitions with `define` keyword
- Control flow structures (`if`, `for`, `while`)
- Variable assignments and pointer operations
- Array indexing and literals
- String literals with proper quote handling
- Numeric literals
- File inclusion with `include` keyword

## Prerequisites

### Required

- **Zig Compiler**: Version 0.11.0 or newer
  - Download from: https://ziglang.org/download/
  - Verify installation: `zig version`

### Optional

- A text editor or IDE with Zig support
- Git (if cloning the repository)

## Installation

### Option 1: Install Zig

1. **Download Zig**:

   - Go to https://ziglang.org/download/
   - Download the appropriate version for your OS
   - Extract the archive to a directory (e.g., `/usr/local/zig` or `C:\zig`)

2. **Add to PATH**:

   - **Linux/macOS**: Add to your shell profile (`.bashrc`, `.zshrc`):
     ```bash
     export PATH=$PATH:/path/to/zig
     ```
   - **Windows**: Add the Zig directory to your system PATH environment variable

3. **Verify Installation**:
   ```bash
   zig version
   # Should output something like: 0.14.0 or newer
   ```

### Option 2: Package Manager Installation

- **macOS (Homebrew)**: `brew install zig`
- **Arch Linux**: `pacman -S zig`
- **Ubuntu/Debian**: Check https://ziglang.org/download/ for latest packages

## Building and Running

### Step-by-Step Build Process

1. **Clone or download this project**:

   ```bash
   git clone <repository-url>
   cd <project-directory>
   ```

2. **Build the lexer**:

   ```bash
   zig build
   ```

   This creates the executable in `zig-out/bin/`

3. **Run the lexer on a source file**:

   ```bash
   # Using zig build run (recommended)
   zig build run -- psudo-syntax.ᛏᛒ

   # Or run the executable directly
   ./zig-out/bin/compiler psudo-syntax.ᛏᛒ
   ```

4. **Check the output**:
   ```bash
   cat tokens
   # Shows the tokenized output
   ```

### Build Commands Reference

```bash
# Clean build
zig build

# Build and run with file argument
zig build run -- <source_file>

# Run all tests
zig build test

# Clean build artifacts
rm -rf zig-cache zig-out
```

### Example Usage

```bash
# Tokenize the included sample file
zig build run -- psudo-syntax.ᛏᛒ

# This creates a 'tokens' file with the tokenized output
cat tokens

# Try with your own source file
echo 'define test() { return 42; }' > my_code.tb
zig build run -- my_code.tb
cat tokens
```

### What Happens When You Run It

1. The lexer reads your source file character by character
2. It identifies tokens (keywords, identifiers, operators, etc.)
3. It writes the tokens to a file called `tokens` in the current directory
4. **That's it** - no compilation, no executable generation, just tokenization

## IMPORTANT

    ### i am using zig version 0.14.0-dev.2371+c013f45ad
    ### could be have breaking changes

## Input/Output Example

**Input** (`psudo-syntax.ᛏᛒ`):

```
define subtracting(number1,number2){
    return number1 - number2 ;
}

greeting = "heisann";
```

**Output** (`tokens` file):

```
k(define)  i(subtracting)  s(()  i(number1)  s(,)  i(number2)  s())  s({)  k(return)  i(number1)  o(-)  i(number2)  s(;)  s(})  i(greeting)  o(=)  l(heisann)  s(;)
```

## Project Structure

```
├── src/
│   ├── main.zig           # Main lexer implementation
│   └── lexer_test.zig     # Comprehensive test suite
├── build.zig              # Zig build configuration
├── build.zig.zon          # Package configuration
├── psudo-syntax.ᛏᛒ        # Sample source code
├── tokens                 # Generated token output
└── parsing.c              # Experimental C parser (separate)
```

## Current Limitations

**IMPORTANT: This is only a lexer, not a compiler**

- **No parser**: Only tokenizes, doesn't build an Abstract Syntax Tree (AST)
- **No semantic analysis**: Doesn't check for type errors, undefined variables, or logic errors
- **No code generation**: Cannot produce executable code or bytecode
- **No preprocessing**: File inclusion (`include` statements) are recognized but not processed
- **No optimization**: No code improvement passes
- **Limited error handling**: Basic error reporting for malformed tokens only

**What this means**: You can see how your code breaks down into tokens, but you cannot run or execute the code.

## Known Issues

1. **Multi-character operators**: `++`, `==`, `!=` are tokenized as separate single-character operators
2. **Block comments**: Only line comments (`//`) are supported, not block comments (`/* */`)

## Testing

The project includes a comprehensive test suite covering:

- Individual token type recognition
- Complex expression tokenization
- Edge cases (unterminated strings, EOF handling)
- Line number tracking
- Whitespace handling

Run tests with:

```bash
zig build test
```

## Future Development

This lexer serves as the foundation for a complete compiler. Next steps would include:

1. **Parser**: Build an Abstract Syntax Tree (AST) from tokens
2. **Semantic Analyzer**: Type checking and symbol table management
3. **Code Generator**: Produce target machine code or bytecode
4. **Optimizer**: Improve generated code performance

## Contributing

The codebase is well-structured and tested. Key areas for contribution:

- Fix hex literal parsing
- Add support for multi-character operators
- Implement block comments
- Add more comprehensive error reporting
- Begin parser implementation

## Technical Details

- **Language**: Zig
- **Architecture**: Single-pass lexer with lookahead
- **Memory Management**: Arena allocator for simplicity
- **Testing**: Comprehensive unit tests for all components
- **Output Format**: Space-separated tokens with type prefixes

This is a solid foundation for a compiler project, with clean, well-tested code that correctly implements lexical analysis for a C-like language syntax.

- [GitHub Discussions](https://github.com/tyrbal-lang/tyrbal/discussions)
- [Discord Server](https://discord.gg/tyrbal)
- [Twitter](https://twitter.com/tyrbal_lang)

---

## 📜 License

Tyrbal is open-source and licensed under the **MIT License**. See [LICENSE](https://github.com/tyrbal-lang/tyrbal/blob/main/LICENSE) for details.

---

**Tyrbal**: Where functional elegance meets systems-level power. Build the future, one saga at a time. 🛡️⚔️
