# Clone command naming tests
# Spec: command_line.md (clone command)

section "clone-naming"

# Test: Clone extracts user-repo from URL (strips .git)
output=$(try_run --path="$TEST_TRIES" exec clone https://github.com/user/myrepo.git 2>&1)
# Should have 'user-myrepo' in the target path (the cd destination), not 'myrepo.git'
# The URL still has .git, but the target directory should not
if echo "$output" | grep -qE "cd '[^']*user-myrepo'"; then
    pass
else
    fail "clone should extract user-repo from URL" "cd path ends with user-myrepo" "$output" "command_line.md#clone"
fi

# Test: Clone extracts user-repo from simple URL
output=$(try_run --path="$TEST_TRIES" exec clone https://github.com/user/simple-repo 2>&1)
if echo "$output" | grep -q "user-simple-repo"; then
    pass
else
    fail "clone should extract user-repo from URL" "user-simple-repo" "$output" "command_line.md#clone"
fi

# Test: Clone with custom name uses that name (no user prefix)
output=$(try_run --path="$TEST_TRIES" exec clone https://github.com/user/repo customname 2>&1)
if echo "$output" | grep -q "customname"; then
    pass
else
    fail "clone with custom name should use that name" "customname" "$output" "command_line.md#clone"
fi

# Test: Directory naming includes date prefix (YYYY-MM-DD-user-repo format)
output=$(try_run --path="$TEST_TRIES" exec clone https://github.com/user/testrepo 2>&1)
# Should have date prefix pattern with user-repo
if echo "$output" | grep -qE "[0-9]{4}-[0-9]{2}-[0-9]{2}-user-testrepo"; then
    pass
else
    fail "clone directory should have YYYY-MM-DD-user-repo format" "YYYY-MM-DD-user-testrepo" "$output" "command_line.md#clone"
fi

# Test: Clone script includes the target path
output=$(try_run --path="$TEST_TRIES" exec clone https://github.com/user/repo 2>&1)
# git clone should specify the target directory
if echo "$output" | grep -q "git clone.*$TEST_TRIES"; then
    pass
else
    fail "clone should specify target directory" "git clone ... path" "$output" "command_line.md#clone"
fi

# Test: TRY_GH_ROOT uses owner/repo layout for GitHub URLs
TEST_GH_ROOT="$TEST_ROOT/github-root"
output=$(TRY_GH_ROOT="$TEST_GH_ROOT" try_run --path="$TEST_TRIES" exec clone https://github.com/user/repo 2>&1)
if echo "$output" | grep -q "cd '$TEST_GH_ROOT/user/repo'"; then
    pass
else
    fail "TRY_GH_ROOT should use owner/repo clone destination" "cd '$TEST_GH_ROOT/user/repo'" "$output" "command_line.md#clone"
fi

# Test: GH_PATH is ignored because GitHub CLI uses it for the gh binary path
output=$(GH_PATH="$TEST_GH_ROOT" try_run --path="$TEST_TRIES" exec clone https://github.com/user/repo 2>&1)
if echo "$output" | grep -q "cd '$TEST_TRIES/" && ! echo "$output" | grep -q "$TEST_GH_ROOT/user/repo"; then
    pass
else
    fail "GH_PATH should not affect clone destination" "date-prefixed path under TRY_PATH" "$output" "command_line.md#environment"
fi
