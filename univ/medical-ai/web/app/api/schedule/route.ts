import { NextResponse } from "next/server"

type ScheduleRequest = {
  send_to: string
  datetime: string
  spreadsheet_url: string[]
}

export async function POST(request: Request) {
  const body: ScheduleRequest = await request.json()

  try {
    // Here, you would typically send this data to your backend service
    // For now, we'll just log it and return a success response
    console.log("Received schedule request:", body)

    // Simulate sending to your backend
    const backendResponse = await fetch("https://your-backend-url.com/schedule", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    })

    if (!backendResponse.ok) {
      throw new Error("Backend service failed")
    }

    return NextResponse.json({ message: "Schedule created successfully" }, { status: 200 })
  } catch (error) {
    console.error("Error creating schedule:", error)
    return NextResponse.json({ error: "Failed to create schedule" }, { status: 500 })
  }
}

