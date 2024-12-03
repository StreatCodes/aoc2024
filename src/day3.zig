const std = @import("std");
const allocator = std.heap.page_allocator;

const Token = enum { instruction, openBracket, closeBracket, number, comma };

//Actually built a parser because zig doesn't have regex
const Tokenizer = struct {
    text: []const u8,
    current: Token,
    index: usize,
    enabled: bool = true,
    value1: ?i32 = null,
    value2: ?i32 = null,

    pub fn init(text: []const u8) Tokenizer {
        return Tokenizer{ .text = text, .current = Token.instruction, .index = 0 };
    }

    pub fn next(self: *Tokenizer) ?i32 {
        if (self.text.len == self.index) {
            return null;
        }

        sw: switch (self.current) {
            Token.instruction => {
                self.value1 = null;
                self.value2 = null;

                var count = self.consumeText("mul");
                if (self.enabled and count != null) {
                    self.index += count.?;
                    self.current = Token.openBracket;
                    break :sw;
                }

                count = self.consumeText("do()");
                if (count != null) {
                    self.index += count.?;
                    self.enabled = true;
                    break :sw;
                }

                count = self.consumeText("don't()");
                if (count != null) {
                    self.index += count.?;
                    self.enabled = false;
                    break :sw;
                }

                self.reset();
                break :sw;
            },
            Token.openBracket => {
                const count = self.consumeText("(") orelse {
                    self.reset();
                    break :sw;
                };

                self.index += count;
                self.current = Token.number;
            },
            Token.number => {
                const count = self.consumeDigit() orelse {
                    self.reset();
                    break :sw;
                };

                const number = std.fmt.parseInt(i32, self.text[self.index .. self.index + count], 10) catch {
                    self.reset();
                    break :sw;
                };
                self.index += count;
                if (self.value1 == null) {
                    self.value1 = number;
                    self.current = Token.comma;
                } else {
                    self.value2 = number;
                    self.current = Token.closeBracket;
                }
            },
            Token.comma => {
                const count = self.consumeText(",") orelse {
                    self.reset();
                    break :sw;
                };

                self.index += count;
                self.current = Token.number;
            },
            Token.closeBracket => {
                const count = self.consumeText(")") orelse {
                    self.reset();
                    break :sw;
                };

                self.index += count;
                self.current = Token.instruction;
                std.debug.print("{d} * {d}\n", .{ self.value1.?, self.value2.? });
                return self.value1.? * self.value2.?;
            },
        }
        return self.next();
    }

    fn reset(self: *Tokenizer) void {
        self.index += 1;
        self.current = Token.instruction;
        self.value1 = null;
        self.value2 = null;
    }

    fn consumeText(self: *Tokenizer, text: []const u8) ?usize {
        if (self.text.len - self.index < text.len) return null;
        const valid = std.mem.eql(u8, self.text[self.index .. self.index + text.len], text);

        if (!valid) return null else return text.len;
    }

    fn consumeDigit(self: *Tokenizer) ?usize {
        var count: usize = 0;
        for (self.text[self.index..]) |c| {
            if (c >= '0' and c <= '9') {
                count += 1;
            } else {
                break;
            }
        }
        if (count == 0) return null;
        return count;
    }
};

pub fn main() !void {
    const text = @embedFile("inputs/3.txt");

    var total: i32 = 0;
    var tokens = Tokenizer.init(text);
    while (tokens.next()) |result| {
        total += result;
    }

    std.debug.print("Total: {d}!\n", .{total});
}
