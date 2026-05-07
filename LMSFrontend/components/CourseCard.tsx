"use client"
import React from 'react'
import { Menubar, MenubarCheckboxItem, MenubarContent, MenubarItem, MenubarMenu, MenubarSeparator, MenubarShortcut, MenubarTrigger } from './ui/menubar'
import Link from 'next/link'

interface CourseCardProps {
    course: {
        id: number;
        title: string;
        description: string;
        instructorName: string;
        instructorImage?: string;
        courseImage?: string;
        durationHours?: number;
        rating?: number;
        reviewCount?: number;
    }
}

const CourseCard = ({ course }: CourseCardProps) => {
    return (
        <>
            <div
                className="group bg-surface-container-lowest rounded-3xl overflow-hidden hover:shadow-[0px_12px_32px_rgba(0,51,102,0.06)] transition-all duration-500 relative">

                {/* Three Dots Icon - Top Right */}
                <div className="absolute top-4 right-4 z-10">
                    <Menubar className="border-none bg-transparent p-0">
                        <MenubarMenu>
                            <MenubarTrigger className="p-0">
                                <div
                                    className="w-8 h-8 rounded-full bg-white/90 hover:bg-white shadow-md flex items-center justify-center transition-all hover:scale-110 cursor-pointer"
                                >
                                    <span className="material-symbols-outlined text-gray-700">more_vert</span>
                                </div>
                            </MenubarTrigger>
                            <MenubarContent 
                                className="w-64"
                                align="end"  // Aligns to the right edge
                                sideOffset={5}  // Adds small gap
                            >
                                <MenubarCheckboxItem>Enroll in Course</MenubarCheckboxItem>
                                <MenubarSeparator />
                                <MenubarItem asChild>
                                    <Link href={`/Course/${course.id}`}>View Details</Link>
                                </MenubarItem>
                                <MenubarItem>Share Course</MenubarItem>
                                <MenubarSeparator />
                                <MenubarItem className="text-red-600">Report</MenubarItem>
                            </MenubarContent>
                        </MenubarMenu>
                    </Menubar>
                </div>

                <div className="aspect-[16/9] overflow-hidden">
                    <img className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                        alt={course.title}
                        src={course.courseImage || "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=800"} />
                </div>
                <div className="p-6">
                    <div className="flex items-center gap-3 mb-4">
                        <img className="w-10 h-10 rounded-full object-cover"
                            alt={course.instructorName}
                            src={course.instructorImage || "https://ui-avatars.com/api/?name=" + course.instructorName} />
                        <span className="text-on-surface-variant font-medium text-sm">{course.instructorName}</span>
                    </div>
                    <h3 className="text-xl font-bold text-primary mb-6 leading-snug">{course.title}</h3>
                    <div className="flex justify-between items-center pt-4 border-t border-surface-container">
                        <div className="flex items-center gap-2 text-on-surface-variant text-sm">
                            <span className="material-symbols-outlined text-sm">schedule</span>
                            {course.durationHours || 10} Hours
                        </div>
                        {/* <div className="flex items-center gap-1 text-on-surface-variant text-sm">
                            <span className="material-symbols-outlined text-sm text-yellow-500"
                                style={{ fontVariationSettings: "FILL 1" }}>star</span>
                            {course.rating || 4.5} ({course.reviewCount || "100"})
                        </div> */}
                    </div>
                </div>
            </div>
        </>
    )
}

export default CourseCard
