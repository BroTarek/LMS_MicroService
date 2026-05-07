"use client"

import { ColumnDef } from "@tanstack/react-table"
import { EnrolledStudents } from "./data"
import { MoreHorizontal } from "lucide-react"
 
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
 
export const columns: ColumnDef<EnrolledStudents>[] = [
  
  {
    accessorKey: "status",
    header: "Status",
  },
  {
    accessorKey: "studentUsername",
    header: "Student Name",
  },
  
  {
    accessorKey: "requestedAt",   // use camelCase unless your object uses "RequestedAt"
    header: "Requested At",
  },
  {
    accessorKey: "respondedAt",
    header: "Joined At",
  },{
    id: "actions",
    cell: ({ row, table }) => {
      const student = row.original
      const meta = table.options.meta as any
 
      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="h-8 w-8 p-0">
              <span className="sr-only">Open menu</span>
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuLabel>Actions</DropdownMenuLabel>
           
           
            <DropdownMenuSeparator />
            <DropdownMenuItem 
              onClick={() => meta?.handleApprove(student.id)}
              className="text-primary cursor-pointer"
            >
              Accept student 
            </DropdownMenuItem>
            <DropdownMenuItem 
              onClick={() => meta?.handleReject(student.id)}
              className="text-destructive cursor-pointer"
            >
              {student.status === 'APPROVED' ? 'Block student' : 'Reject student'}
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      )
    },
  }
]