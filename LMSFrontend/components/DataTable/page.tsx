import { columns } from "./columns"
import {EnrolledStudents} from './data'
import { DataTable } from "./DataTable"

async function getData(): Promise<EnrolledStudents[]> {
  // Fetch data from your API here.
  return [
    {
      id: 3,
      studentUsername: "Shafiq",
      status: "APPROVED",
      requestedAt: "2026-05-04",
      respondedAt: "2026-05-04"
    },
    // ...
  ]
}

export default async function DemoPage() {
  const data = await getData()

  return (
    <div className="container mx-auto py-10">
      <DataTable columns={columns} data={data} />
    </div>
  )
}