import { NextResponse } from "next/server"

type ScheduleRequest = {
  send_to: string
  datetime: string
  spreadsheet_url: string[]
}

export async function POST(request: Request) {
  const body: ScheduleRequest = await request.json()

  try {
    // ここで通常はバックエンドサービスにこのデータを送信します
    // 今回はログに記録して成功レスポンスを返すだけにします
    console.log("スケジュールリクエストを受信:", body)

    // バックエンドへの送信をシミュレート
    const backendResponse = await fetch("https://your-backend-url.com/schedule", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    if (!backendResponse.ok) {
      throw new Error("バックエンドサービスが失敗しました")
    }

    return NextResponse.json({ message: "スケジュールが正常に作成されました" }, { status: 200 })
  } catch (error) {
    console.error("スケジュールの作成中にエラーが発生しました:", error)
    return NextResponse.json({ error: "スケジュールの作成に失敗しました" }, { status: 500 })
  }
}

