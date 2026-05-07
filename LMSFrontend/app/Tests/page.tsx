"use client"
import { enrollApi } from '@/lib/api'
import React, { useEffect } from 'react'


const page = () => {
 useEffect(()=>{
    const fetchEnrollments = async () => {
        try {
            const res = await enrollApi.enrollments(4) // Pass a sample courseId
            console.log("Enrollments:", res)
        } catch (error) {
            console.error("Error fetching enrollments:", error)
        }
    }
    fetchEnrollments()
 },[])
  return (
    <div>page</div>
  )
}

export default page