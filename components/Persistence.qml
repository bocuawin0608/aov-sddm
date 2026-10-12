import QtQuick
import QtQuick.LocalStorage

Item {
    id: persistence

    property string lastUser: ""
    property var savedUsers: []
    property int lastSessionIndex: -1

    signal accountChanged(string username)

    // Regex validating safe Linux username (POSIX standard + system users)
    function isValidUsername(name) {
        if (!name || typeof name !== "string") return false;
        var trimmed = name.trim();
        if (trimmed.length === 0 || trimmed.length > 32) return false;
        var regex = /^[a-zA-Z0-9_.][a-zA-Z0-9_.-]{0,31}$/;
        return regex.test(trimmed);
    }

    function getDatabase() {
        try {
            return LocalStorage.openDatabaseSync("AovThemeDb", "1.0", "AOV SDDM Theme Storage", 100000);
        } catch (err) {
            console.log("Persistence LocalStorage open error:", err);
            return null;
        }
    }

    function initStorage() {
        var db = getDatabase();
        if (!db) return;

        try {
            db.transaction(function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS AovAccounts (username TEXT PRIMARY KEY, last_used INTEGER, role TEXT)');
                try {
                    tx.executeSql('ALTER TABLE AovAccounts ADD COLUMN role TEXT');
                } catch (migErr) {}
                tx.executeSql('CREATE TABLE IF NOT EXISTS AovMeta (key TEXT PRIMARY KEY, val TEXT)');
            });
            reload();
        } catch (e) {
            console.log("Persistence initStorage error:", e);
        }
    }

    function reload() {
        var db = getDatabase();
        if (!db) return;

        try {
            db.readTransaction(function(tx) {
                // Read lastUser
                var rsMeta = tx.executeSql('SELECT val FROM AovMeta WHERE key = "lastUser"');
                if (rsMeta.rows.length > 0) {
                    var candidate = rsMeta.rows.item(0).val;
                    if (isValidUsername(candidate)) {
                        persistence.lastUser = candidate;
                    } else {
                        persistence.lastUser = "";
                    }
                } else {
                    persistence.lastUser = "";
                }

                // Read lastSession
                var rsSession = tx.executeSql('SELECT val FROM AovMeta WHERE key = "lastSessionIndex"');
                if (rsSession.rows.length > 0) {
                    var sessIdx = parseInt(rsSession.rows.item(0).val);
                    persistence.lastSessionIndex = isNaN(sessIdx) ? -1 : sessIdx;
                }

                // Read all saved users sorted by recency
                var rsUsers = tx.executeSql('SELECT username FROM AovAccounts ORDER BY last_used DESC LIMIT 20');
                var list = [];
                for (var i = 0; i < rsUsers.rows.length; i++) {
                    var u = rsUsers.rows.item(i).username;
                    if (isValidUsername(u)) {
                        list.push(u);
                    }
                }
                persistence.savedUsers = list;
            });
        } catch (e) {
            console.log("Persistence reload error:", e);
        }
    }

    function saveUser(username) {
        if (!isValidUsername(username)) {
            console.log("Persistence: rejecting invalid username:", username);
            return false;
        }

        var db = getDatabase();
        if (!db) return false;

        try {
            var now = Date.now();
            db.transaction(function(tx) {
                tx.executeSql('INSERT OR REPLACE INTO AovAccounts (username, last_used) VALUES (?, ?)', [username, now]);
                tx.executeSql('INSERT OR REPLACE INTO AovMeta (key, val) VALUES ("lastUser", ?)', [username]);
            });
            persistence.lastUser = username;
            reload();
            persistence.accountChanged(username);
            return true;
        } catch (e) {
            console.log("Persistence saveUser error:", e);
            return false;
        }
    }

    function removeUser(username) {
        if (!username) return;

        var db = getDatabase();
        if (!db) return;

        try {
            db.transaction(function(tx) {
                tx.executeSql('DELETE FROM AovAccounts WHERE username = ?', [username]);
                var rs = tx.executeSql('SELECT username FROM AovAccounts ORDER BY last_used DESC LIMIT 1');
                if (rs.rows.length > 0) {
                    var nextUser = rs.rows.item(0).username;
                    tx.executeSql('INSERT OR REPLACE INTO AovMeta (key, val) VALUES ("lastUser", ?)', [nextUser]);
                    persistence.lastUser = nextUser;
                } else {
                    tx.executeSql('DELETE FROM AovMeta WHERE key = "lastUser"');
                    persistence.lastUser = "";
                }
            });
            reload();
        } catch (e) {
            console.log("Persistence removeUser error:", e);
        }
    }

    function saveSessionIndex(index) {
        var db = getDatabase();
        if (!db || typeof index !== "number" || index < 0) return;

        try {
            db.transaction(function(tx) {
                tx.executeSql('INSERT OR REPLACE INTO AovMeta (key, val) VALUES ("lastSessionIndex", ?)', [index.toString()]);
            });
            persistence.lastSessionIndex = index;
        } catch (e) {
            console.log("Persistence saveSessionIndex error:", e);
        }
    }

    function isSudoUser(username) {
        if (!username) return false;
        var sudoConfig = (typeof config !== "undefined" && config.sudoAccounts) ? config.sudoAccounts : "loliconhihi,duckneee,bocuawin0608,dotfile-test";
        var list = [];
        if (typeof sudoConfig === "string") {
            list = sudoConfig.split(",");
        } else if (sudoConfig && typeof sudoConfig.length === "number") {
            for (var k = 0; k < sudoConfig.length; k++) {
                list.push(String(sudoConfig[k]));
            }
        } else if (sudoConfig && typeof sudoConfig.toString === "function") {
            list = sudoConfig.toString().split(",");
        }
        for (var i = 0; i < list.length; i++) {
            if (String(list[i]).trim() === username) return true;
        }

        var db = getDatabase();
        if (db) {
            try {
                var found = false;
                db.readTransaction(function(tx) {
                    var rs = tx.executeSql('SELECT role FROM AovAccounts WHERE username = ? AND role = "sudo"', [username]);
                    if (rs.rows.length > 0) found = true;
                });
                if (found) return true;
            } catch (e) {}
        }
        return false;
    }

    function isOfflineUser(username) {
        if (!username) return false;
        var lower = username.toLowerCase();
        var offlineCfg = (typeof config !== "undefined" && config.offlineAccount) ? String(config.offlineAccount).toLowerCase() : "guest";
        return lower === offlineCfg || lower === "guest" || lower === "offline" || lower.indexOf("offline") !== -1 || lower === "kiosk";
    }

    function registerUser(username, role) {
        if (!isValidUsername(username)) return false;
        var db = getDatabase();
        if (!db) return false;

        try {
            var now = Date.now();
            var targetRole = role || "standard";
            db.transaction(function(tx) {
                tx.executeSql('INSERT OR REPLACE INTO AovAccounts (username, last_used, role) VALUES (?, ?, ?)', [username, now, targetRole]);
                tx.executeSql('INSERT OR REPLACE INTO AovMeta (key, val) VALUES ("lastUser", ?)', [username]);
            });
            persistence.lastUser = username;
            reload();
            persistence.accountChanged(username);
            return true;
        } catch (e) {
            console.log("Persistence registerUser error:", e);
            return false;
        }
    }

    function clearAll() {
        var db = getDatabase();
        if (!db) return;

        try {
            db.transaction(function(tx) {
                tx.executeSql('DELETE FROM AovAccounts');
                tx.executeSql('DELETE FROM AovMeta WHERE key = "lastUser"');
            });
            persistence.lastUser = "";
            persistence.savedUsers = [];
        } catch (e) {
            console.log("Persistence clearAll error:", e);
        }
    }

    Component.onCompleted: {
        initStorage();
    }
}

