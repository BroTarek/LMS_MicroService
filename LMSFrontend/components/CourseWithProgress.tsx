"use client"
import { useRouter } from 'next/navigation'
import React from 'react'

interface CourseWithProgressProps {
    course: {
        id: number;
        title: string;
        instructorName: string;
        courseImage?: string;
        progress?: number;
    }
}

const CourseWithProgress = ({ course }: CourseWithProgressProps) => {
    const router = useRouter()
    const progress = course.progress || 0;

    return (
        <div
            onClick={() => router.push(`/Course/${course.id}`)}
            className="group bg-surface-container-lowest rounded-[2rem] overflow-hidden hover:shadow-xl transition-all duration-500 border border-outline-variant/20 cursor-pointer">
            <div className="aspect-[2/1] overflow-hidden relative">
                <img alt={course.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                    src={course.courseImage || "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=800"} />
            </div>
            <div className="p-8">
                <h3 className="text-xl font-bold text-primary mb-1 leading-tight">{course.title}</h3>
                <p className="text-on-surface-variant text-sm mb-6">{course.instructorName}</p>
                <div className="space-y-2">
                    <div className="flex justify-between text-xs font-bold text-primary mb-1">
                        <span>PROGRESS</span>
                        <span>{progress}%</span>
                    </div>
                    <div className="w-full h-2 bg-surface-container-highest rounded-full overflow-hidden">
                        <div className="h-full bg-primary rounded-full" style={{ width: `${progress}%` }}></div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default CourseWithProgress
