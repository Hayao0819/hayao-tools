from flask import Flask, request, redirect, render_template_string
import sqlite3
from pathlib import Path

app = Flask(__name__)
DB = "demo.db"

LOGIN_HTML = """
<h2>Login (VULNERABLE)</h2>
<form method="post" action="/login">
  id: <input name="id"><br>
  pw: <input name="pw" type="password"><br>
  <button type="submit">Login</button>
</form>
<p style="color:#666">※このアプリはSQLインジェクション教材のため意図的に脆弱です。</p>
"""

MAIN_HTML = "<h2>MAIN</h2><p>ログイン成功</p>"

def init_db():
    if Path(DB).exists():
        return
    con = sqlite3.connect(DB)
    cur = con.cursor()
    cur.execute("CREATE TABLE info (id TEXT PRIMARY KEY, pw TEXT)")
    cur.execute("INSERT INTO info (id, pw) VALUES (?, ?)", ("alice", "password123"))
    cur.execute("INSERT INTO info (id, pw) VALUES (?, ?)", ("bob", "letmein"))
    con.commit()
    con.close()

@app.route("/", methods=["GET"])
def index():
    return render_template_string(LOGIN_HTML)

@app.route("/main", methods=["GET"])
def main():
    return render_template_string(MAIN_HTML)

@app.route("/login", methods=["POST"])
def login():
    user_id = request.form.get("id", "")
    pw = request.form.get("pw", "")

    # ❌ 脆弱：文字列連結でSQLを組み立てている
    sql = f"SELECT * FROM info WHERE id='{user_id}' AND pw='{pw}'"

    con = sqlite3.connect(DB)
    cur = con.cursor()
    print("[DEBUG] SQL =", sql)   # デモ用：実際にどんなSQLになったか見せる
    try:
        cur.execute(sql)
        row = cur.fetchone()
    except Exception as e:
        con.close()
        return f"<pre>SQL error: {e}\n\nSQL was:\n{sql}</pre>", 400

    con.close()
    if row:
        return redirect("/main")
    return redirect("/")

if __name__ == "__main__":
    init_db()
    app.run(host="127.0.0.1", port=5000, debug=True)
