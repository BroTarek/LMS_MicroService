"use client"
import AccordionItem from '@/components/AccordionItem'
import { DataTable } from '@/components/DataTable/DataTable'
import Modal from '@/components/Modal'
import { Plus } from 'lucide-react'
import React, { useState } from 'react'
import { columns } from "../../components/DataTable/columns"
import { EnrolledStudents } from "../../components/DataTable/data"
const page = () => {
    const [showModal,setShowModal]=useState(false)
    return (
        <>
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
                {showModal&&<Modal handleModalVisisbility={()=>setShowModal(p=>!p)}/>}
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-12">
                    {/* <!-- BEGIN: LeftContentColumn --> */}
                    <div className="lg:col-span-8">
                        {/* <!-- BEGIN: InstructorCard --> */}
                        <section className="mb-12" data-purpose="instructor-info">
                            <div className="flex items-center gap-6 p-6 bg-wisdom-gray rounded-2xl border border-gray-100">
                                <img alt="Mustafa Abdelsabour"
                                    className="w-24 h-24 rounded-full object-cover border-4 border-white shadow-sm"
                                    src="https://lh3.googleusercontent.com/aida-public/AB6AXuDAD4W_9vdNBEOlBuw6W9A5W5vThsnmrrboopXPRtY1YzoWNmE70TQ0Ql1dF9R4ZoTqei6t75DL0MBjSXiwXFFbGsjwJKAPTVGtUu5PIymlBmLbwBy8VQTLlvkiPQWsxV9Qn8UxHx76DeeXMyZvFnRXlQEkcMCxdkvuFGx9ITJ5eIV_Ulerp8kIaaOJKXvSx9qownPKWH4Qtgn0BubCqQsLaG0EjNk_g91tiCWye1gD8nZXbTgffUWwos3nIcZm-Ep3hPRG5C3y4L9G"
                                />
                                <div>
                                    <h3 className="text-xl font-bold text-wisdom-blue" >Mustafa Abdelsabour</h3>
                                    <p className="text-gray-500 font-medium mb-2" >English Instructor</p>
                                    <p className="text-sm text-gray-600 leading-relaxed" >
                                        Mustafa Abdel Sabour is an English language teacher with over 7 years of experience in
                                        all levels and ages. Founder of DR.ENGLISH for professional English education.
                                    </p>
                                </div>
                            </div>
                        </section>
                        {/* <!-- END: InstructorCard --> */}
                        {/* <!-- BEGIN: CourseContentAccordion --> */}
                        <section className="mb-16" data-purpose="course-curriculum">
                            <h2 className="text-2xl font-extrabold text-wisdom-blue mb-8" >Course Content</h2>
                            <div className="space-y-4" id="course-accordion">
                                {/* <!-- Accordion Item 1 --> */}


                                {Array.from({ length: 9 }).map((accordionItem, i) => (<AccordionItem key={i} lesson={{
                                    id: 0,
                                    title: '',
                                    content: undefined,
                                    videoUrl: undefined
                                }} index={0} />))}
                            </div>
                        </section>
                        {/* <!-- END: CourseContentAccordion --> */}


                    </div>
                    {/* <!-- END: LeftContentColumn --> */}
                    {/* <!-- BEGIN: RightSidebar --> */}
                    
                    <aside className="lg:col-span-4">
                        <div className="sticky-sidebar bg-white border border-gray-200 rounded-2xl p-6 shadow-sm">
                            <h1 className="text-2xl font-extrabold text-wisdom-blue mb-4" >English Language - Level 1</h1>
                            <p className="text-sm text-gray-600 mb-8 leading-relaxed" >
                                What will you learn here? No doubt that learning English has become essential now. This course
                                takes you from zero to professionalism, giving you everything you need.
                            </p>
                            <div className="space-y-4 mb-8">
                                <button
                                
        onClick={() => setShowModal(true)} 
                                    className="w-full py-4 bg-wisdom-gold text-wisdom-dark font-extrabold rounded-xl hover:bg-[#e6c15c] transition-all shadow-md shadow-wisdom-gold/20"
                                >
                                    <Plus className="inline-block mr-2" /> {/* Added className for sizing/spacing */}
                                    Upload Lesson
                                </button>
                            </div>
                            <div className="space-y-4 pt-6 border-t border-gray-100">
                                <div className="flex items-center justify-between text-sm">
                                    <span className="flex items-center gap-3 text-gray-500 font-medium" >
                                        <svg className="w-5 h-5 text-wisdom-blue" fill="none" stroke="currentColor"
                                            viewBox="0 0 24 24">
                                            <path
                                                d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
                                                strokeLinecap="round" strokeLinejoin="round" strokeWidth="2"></path>
                                        </svg>
                                        Lessons
                                    </span>
                                    <span className="font-bold text-wisdom-blue" >29 Lessons</span>
                                </div>
                                <div className="flex items-center justify-between text-sm">
                                    <span className="flex items-center gap-3 text-gray-500 font-medium" ></span>
                                    <span className="font-bold text-wisdom-blue" ><br /></span>
                                </div>
                                <div className="flex items-center justify-between text-sm">
                                    <span className="flex items-center gap-3 text-gray-500 font-medium" >
                                        <svg className="w-5 h-5 text-wisdom-blue" fill="none" stroke="currentColor"
                                            viewBox="0 0 24 24">
                                            <path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                                                strokeLinecap="round" strokeLinejoin="round" strokeWidth="2"></path>
                                        </svg>
                                        Instructor
                                    </span>
                                    <a className="font-bold text-wisdom-blue hover:underline" href="#" >M. Abdelsabour</a>
                                </div>
                                <div className="flex items-center justify-between text-sm">
                                    <span className="flex items-center gap-3 text-gray-500 font-medium" >
                                        <svg className="w-5 h-5 text-wisdom-blue" fill="none" stroke="currentColor"
                                            viewBox="0 0 24 24">
                                            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" strokeLinecap="round"
                                                strokeLinejoin="round" strokeWidth="2"></path>
                                        </svg>
                                        Level
                                    </span>
                                    <span className="font-bold text-wisdom-blue" >Beginner - 101</span>
                                </div>
                            </div>
                        </div>
                    </aside>

                </div>
            </main>
        </>
    )
}

export default page