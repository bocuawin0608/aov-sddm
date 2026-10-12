#!/usr/bin/env bash
# ==============================================================================
# Test Account Persistence, Data Validation & Malformed Input Handling
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Running Persistence & Input Validation Tests ==="

TEST_QML="${SCRIPT_DIR}/.tmp_test_persistence.qml"
trap 'rm -f "${TEST_QML}"' EXIT

cat << 'EOF' > "${TEST_QML}"
import QtQuick
import QtQuick.LocalStorage
import "../components"

Item {
    id: testRoot

    Persistence {
        id: persistence
    }

    Component.onCompleted: {
        console.log("TEST: Initializing Persistence...");
        persistence.initStorage();

        // 1. Validation test
        var validUsers = ["ralsei", "john_doe", "user.1", "admin-test"];
        for (var i = 0; i < validUsers.length; i++) {
            if (!persistence.isValidUsername(validUsers[i])) {
                console.error("FAIL: valid username rejected:", validUsers[i]);
                Qt.quit();
            }
        }
        console.log("PASS: Valid usernames accepted.");

        var invalidUsers = ["", "   ", "user with spaces", "../etc/passwd", ";rm -rf /", "a".repeat(40), "root$danger"];
        for (var j = 0; j < invalidUsers.length; j++) {
            if (persistence.isValidUsername(invalidUsers[j])) {
                console.error("FAIL: invalid username accepted:", invalidUsers[j]);
                Qt.quit();
            }
        }
        console.log("PASS: Invalid and malicious inputs rejected.");

        // 2. Storage roundtrip test
        persistence.clearAll();
        if (persistence.lastUser !== "" || persistence.savedUsers.length !== 0) {
            console.error("FAIL: clearAll did not reset state.");
            Qt.quit();
        }

        var saveResult = persistence.saveUser("test_warrior");
        if (!saveResult || persistence.lastUser !== "test_warrior") {
            console.error("FAIL: saveUser failed to store warrior.");
            Qt.quit();
        }
        console.log("PASS: saveUser stored user successfully.");

        persistence.saveUser("second_player");
        if (persistence.lastUser !== "second_player" || persistence.savedUsers.length !== 2) {
            console.error("FAIL: multiple accounts tracking failed.");
            Qt.quit();
        }
        console.log("PASS: Multiple accounts tracked correctly.");

        // 3. Account removal test
        persistence.removeUser("second_player");
        if (persistence.lastUser !== "test_warrior" || persistence.savedUsers.length !== 1) {
            console.error("FAIL: removeUser failed to fallback to previous user.");
            Qt.quit();
        }
        // 4. Role privilege classification test
        if (!persistence.isSudoUser("loliconhihi") || !persistence.isSudoUser("duckneee")) {
            console.error("FAIL: isSudoUser failed for system wheel accounts.");
            Qt.quit();
        }
        if (!persistence.isOfflineUser("guest") || !persistence.isOfflineUser("offline_5v5")) {
            console.error("FAIL: isOfflineUser failed for guest/offline accounts.");
            Qt.quit();
        }

        persistence.registerUser("test_sudo_admin", "sudo");
        if (!persistence.isSudoUser("test_sudo_admin")) {
            console.error("FAIL: registered sudo user not recognized.");
            Qt.quit();
        }

        persistence.registerUser("standard_gamer", "standard");
        if (persistence.isSudoUser("standard_gamer")) {
            console.error("FAIL: standard gamer mistakenly classified as sudo.");
            Qt.quit();
        }
        console.log("PASS: Role classification and privilege queries verified.");

        console.log("ALL PERSISTENCE TESTS PASSED SUCCESSFULLY.");
        Qt.quit();
    }
}
EOF

if command -v qml6 &>/dev/null; then
    OUTPUT=$(qml6 "${TEST_QML}" 2>&1 || true)
    echo "${OUTPUT}"
    if echo "${OUTPUT}" | grep -q "ALL PERSISTENCE TESTS PASSED SUCCESSFULLY"; then
        echo "  [PASS] Persistence test harness passed all checks."
    else
        echo "  [FAIL] Persistence test failed!" >&2
        exit 1
    fi
else
    echo "  [WARN] qml6 runner not available for headless test, skipping."
fi

echo "=== Persistence Tests Completed Successfully ==="
