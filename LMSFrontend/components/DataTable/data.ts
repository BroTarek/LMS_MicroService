export type EnrolledStudents = {
  id: number
  studentUsername: string
  status: "PENDING" | "APPROVED" | "REJECTED"
  respondedAt: string
  requestedAt: string
}

export const mockEnrolledStudents: EnrolledStudents[] =
  [
    {
      id: 3,
      studentUsername: "Shafiq",
      status: "APPROVED",
      requestedAt: new Date("2026-05-04T15:09:19.705388").toLocaleDateString(),
      respondedAt: new Date("2026-05-04T15:10:49.465779").toLocaleDateString()
    },
    {
      id: 4,
      studentUsername: "Khaled",
      status: "APPROVED",
      requestedAt: new Date("2026-05-04T15:17:54.126351").toLocaleDateString(),
      respondedAt: new Date("2026-05-04T15:18:07.491184").toLocaleDateString()
    },
    {
      id: 5,
      studentUsername: "jonah",
      status: "APPROVED",
      requestedAt: new Date("2026-05-04T15:27:22.013536").toLocaleDateString(),
      respondedAt: new Date("2026-05-04T15:36:24.647803").toLocaleDateString()
    }
  ]
