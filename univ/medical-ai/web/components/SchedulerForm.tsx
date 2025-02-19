"use client"

import type React from "react"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { useToast } from "@/components/ui/use-toast"
import { DateTimePicker } from "@/components/ui/date-time-picker"

export default function SchedulerForm() {
  const [email, setEmail] = useState("")
  const [dateTime, setDateTime] = useState<Date | undefined>(undefined)
  const [spreadsheetUrls, setSpreadsheetUrls] = useState([""])
  const { toast } = useToast()

  const handleAddUrl = () => {
    setSpreadsheetUrls([...spreadsheetUrls, ""])
  }

  const handleUrlChange = (index: number, value: string) => {
    const newUrls = [...spreadsheetUrls]
    newUrls[index] = value
    setSpreadsheetUrls(newUrls)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!email || !dateTime || spreadsheetUrls.some((url) => !url)) {
      toast({
        title: "エラー",
        description: "すべての項目を入力してください",
        variant: "destructive",
      })
      return
    }

    const payload = {
      send_to: email,
      datetime: dateTime.toISOString(),
      spreadsheet_url: spreadsheetUrls.filter((url) => url.trim() !== ""),
    }

    try {
      const response = await fetch("/api/schedule", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      })

      if (response.ok) {
        toast({
          title: "成功",
          description: "スケジュールが正常に作成されました",
        })
        // フォームをリセット
        setEmail("")
        setDateTime(undefined)
        setSpreadsheetUrls([""])
      } else {
        throw new Error("スケジュールの作成に失敗しました")
      }
    } catch (error) {
      toast({
        title: "エラー",
        description: "スケジュールの作成に失敗しました。もう一度お試しください。",
        variant: "destructive",
      })
    }
  }

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle>スプレッドシート集計のスケジュール</CardTitle>
        <CardDescription>スプレッドシート集計タスクのスケジュールの詳細を入力してください。</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="email">メールアドレス</Label>
            <Input
              id="email"
              type="email"
              placeholder="メールアドレスを入力"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="datetime">日時</Label>
            <DateTimePicker value={dateTime} onChange={setDateTime} />
          </div>
          <div className="space-y-2">
            <Label>スプレッドシートURL</Label>
            {spreadsheetUrls.map((url, index) => (
              <Input
                key={index}
                type="url"
                placeholder="スプレッドシートのURLを入力"
                value={url}
                onChange={(e) => handleUrlChange(index, e.target.value)}
                required
              />
            ))}
            <Button type="button" variant="outline" onClick={handleAddUrl}>
              URLを追加
            </Button>
          </div>
        </form>
      </CardContent>
      <CardFooter>
        <Button onClick={handleSubmit} className="w-full">
          スケジュール
        </Button>
      </CardFooter>
    </Card>
  )
}

