# eksek

`eksek` is a library to run shell commands synchronously and obtain any of the standard output, standard error, and exit code with flexibility.

## Features

### Basic methods

- `exit` returns the exit code.
- `stdout` returns the standard output as a string.
- `stderr` returns the standard error as a string.
- `stdouterr` returns the standard output and error in a single string.
- `success?` returns `true` or `false` depending of the exit code (`0` for `true`).
- `success!` throws an exception if the command exited with a non-0 code.

For example

```ruby
puts Eksek.stdout 'echo Hello' # Hello
```

### Chaining methods together

Any of the above methods can be chained in almost any order, except `success?` and `success!`, which can only occur at the end of the method; and `stdout` and `stderr` cannot be used together with `stdouterr`.

For example:

```ruby
stdout, stderr = Eksek.stdout_stderr_success! 'echo Hello; echo World >&2'
puts stdout # Hello
puts stderr # World
```

### Writing to stdin

To write into the standard input a block can be used:

```ruby
Eksek.success! 'read A; echo $A' { |stdin| stdin.write "Hello" }
```

If the block returns a `String` or `IO`, it will be written into the stdio.

```ruby
Eksek.success! 'read A; echo $A' { "Hello" }
Eksek.success! 'read A; echo $A' { File.open('myfile.txt') }
```


### Passing other options

Any of those methods can accept a hash of options, according to `Process::spawn`.

Additionally, a hash passed as `:env` will have its keys stringified, so that symbols can be used to. For example:

```ruby
Eksek.stdout 'echo $A', env: {A: "Hello"} # Hello

Eksek.stdout 'echo $PWD', chdir: '/tmp' # /tmp
```
