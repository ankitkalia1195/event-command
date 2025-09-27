# Git Hooks Documentation

## Pre-Push Hook

This project includes a pre-push hook that automatically runs the test suite before allowing any push to remote repositories.

### How it works

1. **Automatic execution**: The hook runs automatically whenever you execute `git push`
2. **Test execution**: Runs `bundle exec rails test` to execute the full test suite
3. **Database preparation**: Automatically prepares the test database before running tests
4. **Push prevention**: If any tests fail, the push is rejected
5. **Success indication**: If all tests pass, the push proceeds normally

### Usage

#### Normal push (with tests)
```bash
git push origin main
```

#### Skip tests temporarily
```bash
SKIP_TESTS=1 git push origin main
```

#### Skip tests with true value
```bash
SKIP_TESTS=true git push origin main
```

### Output Examples

#### ✅ When tests pass:
```
🧪 Running tests before push...

📋 Branch: main
📦 Checking bundle...
🗄️ Preparing test database...
🚀 Running test suite...

✅ All tests passed!
   70 runs, 135 assertions, 0 failures, 0 errors, 16 skips
   
🎉 Push allowed - tests are passing
```

#### ❌ When tests fail:
```
🧪 Running tests before push...

📋 Branch: feature-branch
📦 Checking bundle...
🗄️ Preparing test database...
🚀 Running test suite...

❌ Tests failed!

📋 Test output:
[detailed test failure output]

🚫 Push rejected - fix failing tests first

💡 To skip tests temporarily:
   SKIP_TESTS=1 git push

💡 To run tests manually:
   bundle exec rails test
```

#### ⚠️ When tests are skipped:
```
⚠️ Tests skipped due to SKIP_TESTS environment variable
   To run tests: unset SKIP_TESTS or SKIP_TESTS=0 git push
```

### Configuration

#### Disable the hook temporarily
Set the `SKIP_TESTS` environment variable:
```bash
export SKIP_TESTS=1
git push origin main
unset SKIP_TESTS
```

#### Disable the hook permanently
Remove or rename the hook file:
```bash
# Disable
mv .git/hooks/pre-push .git/hooks/pre-push.disabled

# Re-enable
mv .git/hooks/pre-push.disabled .git/hooks/pre-push
```

### Installation for New Contributors

When cloning the repository, the hook should already be present. If not, you can copy it:

```bash
# Ensure the hook is executable
chmod +x .git/hooks/pre-push

# Test the hook
git push --dry-run
```

### Troubleshooting

#### Hook not running
- Check if the file exists: `ls -la .git/hooks/pre-push`
- Check if it's executable: `ls -la .git/hooks/pre-push` (should show `x` permissions)
- Make it executable: `chmod +x .git/hooks/pre-push`

#### Tests taking too long
- Use `SKIP_TESTS=1` for urgent pushes
- Consider optimizing slow tests
- Run tests locally first: `bundle exec rails test`

#### Database issues
The hook automatically runs `rails db:test:prepare`. If this fails:
- Check your database configuration
- Ensure test database exists
- Run manually: `RAILS_ENV=test bundle exec rails db:test:prepare`

### Best Practices

1. **Run tests locally** before pushing to catch issues early
2. **Use skip sparingly** - only for urgent hotfixes or when tests are known to be broken
3. **Fix failing tests** rather than skipping them
4. **Keep tests fast** to make the hook less intrusive

### Integration with CI/CD

This pre-push hook complements (doesn't replace) CI/CD testing:
- **Pre-push hook**: Catches issues before they reach the remote repository
- **CI/CD**: Provides comprehensive testing in isolated environments
- **Both together**: Maximum confidence in code quality
