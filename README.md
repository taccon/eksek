# eksek

[![Travis](https://img.shields.io/travis/jleeothon/eksek.svg)](https://travis-ci.org/jleeothon/eksek)

`eksek` is a library to run shell commands synchronously and obtain any of the standard output, standard error, and exit code with flexibility.

## Features

### Basic usage

Use the `eksek` to execute a command:

```ruby
eksek 'echo Hello'
```

This returns a result object (`EksekResult`) providing the following methods:

- `exit` returns the exit code.
- `stdout` returns the standard output as a string.
- `stderr` returns the standard error as a string.
- `success?` returns `true` or `false` depending of the exit code (`0` for `true`).
- `success!` throws an exception if the command exited with a non-0 code.

The `success!` method can be chained with any other of the above ones and it is wrapped in the convenience method `eksek!` to have a "fail or return" like so:

```ruby
puts eksek!('echo Hello').stdout # Hello

# The above is essentially the same as:

puts eksek('echo Hello').success!.stdout
```

### Writing to stdin

To write into the standard input a block can be used:

```ruby
r = eksek('read A; echo $A') { |stdin| stdin.write "Hello" }
r.success!
```

If the block returns a `String` or `IO`, it will be written into the stdio.

```ruby
r = eksek('read A; echo $A') { "Hello" }
r.success!

r = eksek('read A; echo $A') { File.open('myfile.txt') }
r.success!
```


### Passing other options

The run method can accept a hash of options, according to `Process::spawn`.

Additionally, a hash passed as `:env` will have its keys stringified, so that symbols can be used to. For example:

```ruby
r = eksek 'echo $A', env: {A: "Hello"}
r.stdout # Hello

r = eksek 'echo $PWD', chdir: '/tmp'
r.stdout # /tmp
```

### Further information

In case you prefer an object oriented method, you can also use the `Eksektuter` class that is used by the `eksek` method directly. The following examples are basically the same:

```ruby
eksek 'echo Hello'
```

```ruby
Esekuter.new 'echo Hello'
```
