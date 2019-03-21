# eksek

[![Travis](https://img.shields.io/travis/taccon/eksek.svg)](https://travis-ci.org/taccon/eksek)
[![Coverage Status](https://coveralls.io/repos/github/taccon/eksek/badge.svg?branch=coveralls)](https://coveralls.io/github/taccon/eksek?branch=coveralls)

`eksek` is a library to run shell commands synchronously and obtain any of the standard output, standard error, and exit code with flexibility.

## Features

### Basic usage

Use the `eksek` method to execute a command:

```ruby
eksek 'echo Hello'
```

or the `kapture` method to execute a command but "capture" the standard output and standard error in a fashion similar to `Kernel#\`` (backticks) or `%x()`.

```ruby
kapture 'echo Hello'
```

These methods return an `EksekResult` object providing the following methods:

- `exit` returns the exit code.
- `stdout` returns the standard output as a string if `kapture` was called.
- `stderr` returns the standard error as a string if `kapture` was called.
- `success?` returns `true` or `false` depending of the exit code (`0` for `true`).
- `success!` throws an exception if the command exited with a non-0 code.

The `success!` method can be chained with any other of the above ones and it is wrapped in the convenience method `eksek!` to have a "fail or return" like so:

```ruby
puts eksek!('echo Hello').stdout # Hello

# The above is essentially the same as:

puts eksek('echo Hello').success!.stdout
```

### Passing other options

`eksek` has the same signature as `Process#spawn`. This means that:

- the first parameter can optionally be a hash, passed as the process environment;
- the command can be passed as a single string or as variable-length arguments;
- other options can be passed as hash arguments.

Additionally, the environment will have its keys stringified, so that symbols can be used too. For example:

```ruby
r = eksek { A: 'Hello' }, 'echo $A'
puts r.stdout # Hello

r = eksek 'echo', 'Hello'
puts r.stdout # Hello

r = eksek 'echo $PWD', chdir: '/tmp'
puts r.stdout # /tmp
```

### Further information

In case you prefer an object oriented method, you can also use the `Eksekuter` class that is used by the `eksek` method directly. The following examples are basically the same:

```ruby
# With eksek
eksek 'echo Hello'
kapture 'echo Hello'

# With Eksekuter
Eksekuter.new.exec('echo Hello')
Eksekuter.new.capture('echo Hello')
```
