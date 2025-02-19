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
        title: "Error",
        description: "Please fill in all fields",
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
          title: "Success",
          description: "Schedule created successfully",
        })
        // Reset form
        setEmail("")
        setDateTime(undefined)
        setSpreadsheetUrls([""])
      } else {
        throw new Error("Failed to create schedule")
      }
    } catch (error) {
      toast({
        title: "Error",
        description: "Failed to create schedule. Please try again.",
        variant: "destructive",
      })
    }
  }

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle>Schedule Spreadsheet Aggregation</CardTitle>
        <CardDescription>Enter the details to schedule a spreadsheet aggregation task.</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              placeholder="Enter your email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="datetime">Date and Time</Label>
            <DateTimePicker value={dateTime} onChange={setDateTime} />
          </div>
          <div className="space-y-2">
            <Label>Spreadsheet URLs</Label>
            {spreadsheetUrls.map((url, index) => (
              <Input
                key={index}
                type="url"
                placeholder="Enter spreadsheet URL"
                value={url}
                onChange={(e) => handleUrlChange(index, e.target.value)}
                required
              />
            ))}
            <Button type="button" variant="outline" onClick={handleAddUrl}>
              Add Another URL
            </Button>
          </div>
        </form>
      </CardContent>
      <CardFooter>
        <Button onClick={handleSubmit} className="w-full">
          Schedule
        </Button>
      </CardFooter>
    </Card>
  )
}

