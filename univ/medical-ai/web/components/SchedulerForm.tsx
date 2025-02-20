"use client"

import type React from "react"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { useToast } from "@/components/ui/use-toast"
import { DateTimePicker } from "@/components/ui/date-time-picker"
import { Slider } from "@/components/ui/slider"
import { Textarea } from "@/components/ui/textarea"

export default function SchedulerForm() {
  const [email, setEmail] = useState("")
  const [dateTime, setDateTime] = useState<Date | undefined>(undefined)
  const [spreadsheetUrls, setSpreadsheetUrls] = useState("")
  const [passingScore, setPassingScore] = useState(80)
  const { toast } = useToast()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!email || !dateTime || !spreadsheetUrls.trim()) {
      toast({
        title: "エラー",
        description: "すべての項目を入力してください",
        variant: "destructive",
      })
      return
    }

    // 現在の日時と選択された日時を比較
    const now = new Date()
    if (dateTime <= now) {
      toast({
        title: "エラー",
        description: "過去の日時は選択できません。未来の日時を選択してください。",
        variant: "destructive",
      })
      return
    }

    const urlList = spreadsheetUrls.split("\n").filter((url) => url.trim() !== "")

    const payload = {
      send_to: email,
      datetime: dateTime.toISOString(),
      spreadsheet_url: urlList,
      passing_score: passingScore,
    }

    console.log(payload)

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
        setSpreadsheetUrls("")
        setPassingScore(80)
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
            <Label htmlFor="datetime">日時（未来の日時を選択してください）</Label>
            <DateTimePicker value={dateTime} onChange={setDateTime} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="spreadsheetUrls">スプレッドシートURL（1行に1つのURLを入力）</Label>
            <Textarea
              id="spreadsheetUrls"
              placeholder="スプレッドシートのURLを入力（複数の場合は改行で区切ってください）"
              value={spreadsheetUrls}
              onChange={(e) => setSpreadsheetUrls(e.target.value)}
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="passingScore">合格基準点 ({passingScore})</Label>
            <Slider
              id="passingScore"
              min={0}
              max={100}
              step={0.1}
              value={[passingScore]}
              onValueChange={(value) => setPassingScore(value[0])}
            />
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

