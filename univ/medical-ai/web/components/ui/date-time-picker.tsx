"use client"

import * as React from "react"
import { CalendarIcon } from "@radix-ui/react-icons"
import { format } from "date-fns"
import { ja } from "date-fns/locale"

import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Calendar } from "@/components/ui/calendar"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Input } from "@/components/ui/input"

interface DateTimePickerProps {
  value?: Date
  onChange?: (date: Date | undefined) => void
}

export function DateTimePicker({ value, onChange }: DateTimePickerProps) {
  const [date, setDate] = React.useState<Date | undefined>(value)

  const handleDateChange = (newDate: Date | undefined) => {
    setDate(newDate)
    if (onChange) {
      onChange(newDate)
    }
  }

  const handleTimeChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const timeString = event.target.value
    if (date && timeString) {
      const [hours, minutes] = timeString.split(":")
      const newDate = new Date(date)
      newDate.setHours(Number.parseInt(hours, 10))
      newDate.setMinutes(Number.parseInt(minutes, 10))
      handleDateChange(newDate)
    }
  }

  return (
    <div className="flex gap-2">
      <Popover>
        <PopoverTrigger asChild>
          <Button
            variant={"outline"}
            className={cn("w-[240px] justify-start text-left font-normal", !date && "text-muted-foreground")}
          >
            <CalendarIcon className="mr-2 h-4 w-4" />
            {date ? format(date, "PPP", { locale: ja }) : <span>日付を選択</span>}
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-auto p-0" align="start">
          <Calendar mode="single" selected={date} onSelect={handleDateChange} initialFocus locale={ja} />
        </PopoverContent>
      </Popover>
      <Input type="time" value={date ? format(date, "HH:mm") : ""} onChange={handleTimeChange} className="w-[120px]" />
    </div>
  )
}

