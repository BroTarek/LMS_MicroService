"use client"
import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import AccordionItem from '@/components/AccordionItem'
import Modal from '@/components/Modal'
import { Plus } from 'lucide-react'
import React from 'react'
import { courseApi, enrollApi } from "@/lib/api";
import { DataTable } from "@/components/DataTable/DataTable";
import { columns } from "@/components/DataTable/columns";
import { EnrolledStudents, mockEnrolledStudents as initialMockData } from "@/components/DataTable/data";

const CourseDetailsPage = () => {
    const { id } = useParams();
    const [user, setUser] = useState<any>(null);
    const [course, setCourse] = useState<any>(null);
    const [pendingEnrollments, setPendingEnrollments] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [mockEnrolledStudents, setmockEnrolledStudents] = useState<EnrolledStudents[]>([]);
    const fetchPendingEnrollments = () => {
        if (id) {
            enrollApi.pending(Number(id))
                .then(setPendingEnrollments)
                .catch(err => console.error("Failed to fetch pending enrollments:", err));
        }
    };

    useEffect(() => {
        const local = localStorage.getItem('user');
        if (local) {
            const userData = JSON.parse(local);
            setUser(userData);
            if (userData.role === 'TEACHER') {
                fetchPendingEnrollments();
            }
        }

        if (id) {
            courseApi.get(id as string)
                .then(data => {
                    console.log(data)
                    setCourse(data);
                    setLoading(false);
                })
                .catch(err => {
                    console.error("Failed to fetch course:", err);
                    setLoading(false);
                });
        }
    }, [id]);
     useEffect(()=>{
        const fetchEnrollments = async () => {
            try {
                const res = await enrollApi.enrollments(Number(id)) // Use dynamic id
                
                console.log("Enrollments:", res)
                setmockEnrolledStudents(res)
            } catch (error) {
                console.error("Error fetching enrollments:", error)
            }
        }
        fetchEnrollments()
     },[])
    const handleApprove = async (enrollmentId: number) => {
        try {
            await enrollApi.approve(enrollmentId);
            // Update both states to ensure consistency
            setPendingEnrollments(prev => prev.filter(e => e.id !== enrollmentId));
            setmockEnrolledStudents(prev => prev.map(e => 
                (e as any).id === enrollmentId ? { ...e, status: 'APPROVED' } : e
            ));
            alert("Enrollment approved successfully!");
        } catch (err) {
            alert("Failed to approve enrollment");
        }
    };

    const handleReject = async (enrollmentId: number) => {
        try {
            await enrollApi.reject(enrollmentId);
            setPendingEnrollments(prev => prev.filter(e => e.id !== enrollmentId));
            setmockEnrolledStudents(prev => prev.map(e => 
                (e as any).id === enrollmentId ? { ...e, status: 'REJECTED' } : e
            ));
            alert("Enrollment rejected.");
        } catch (err) {
            alert("Failed to reject enrollment");
        }
    };

    const handleEnroll = async () => {
        try {
            await enrollApi.request(Number(id));
            alert("Enrollment request sent successfully! Waiting for teacher approval.");
            // Refresh course data to show pending status
            const data = await courseApi.get(id as string);
            setCourse(data);
        } catch (err: any) {
            console.error("Enrollment failed:", err);
            alert(err.message || "Failed to enroll. You might already have a pending request.");
        }
    };

    if (loading) return <div className="text-center py-20">Loading course details...</div>;
    if (!course) return <div className="text-center py-20">Course not found.</div>;

    const enrollment = course.enrollments?.find((e: any) => e.studentUsername === user?.username);
    const isApproved = enrollment?.status === 'APPROVED';
    const isRejected = enrollment?.status === 'REJECTED';
    const isTeacher = user?.role === 'TEACHER' && (course.teacherUsername === user?.username || course.instructorName === user?.username); 
    const canSeeContent = isTeacher || isApproved;

    return (
        <>
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
                {showModal && (
                    <Modal 
                        handleModalVisisbility={() => setShowModal(false)} 
                        type="lesson" 
                        courseId={id as string} 
                    />
                )}
                <div className="grid grid-cols-1 lg:grid-cols-12 gap-12">
                    {/* BEGIN: LeftContentColumn */}
                    <div className="lg:col-span-8">
                        {/* BEGIN: InstructorCard */}
                        <section className="mb-12">
                            <div className="flex items-center gap-6 p-6 bg-surface-container-low rounded-2xl border border-outline-variant/30">
                                <img alt={course.instructorName}
                                    className="w-24 h-24 rounded-full object-cover border-4 border-white shadow-sm"
                                    src={course.instructorImage || "https://ui-avatars.com/api/?name=" + course.instructorName}
                                />
                                <div>
                                    <h3 className="text-xl font-bold text-primary">{course.instructorName}</h3>
                                    <p className="text-on-surface-variant font-medium mb-2">Instructor</p>
                                    <p className="text-sm text-on-surface leading-relaxed">
                                        Expert educator in this field.
                                    </p>
                                </div>
                            </div>
                        </section>
                        {/* END: InstructorCard */}
                        
                       <DataTable 
                         columns={columns} 
                         data={mockEnrolledStudents} 
                         meta={{ handleApprove, handleReject }} 
                       />
                       
                        {/* BEGIN: CourseContentAccordion */}
                        <section className="mb-16">
                            <h2 className="text-2xl font-extrabold text-primary mb-8">Course Content</h2>
                            <div className="space-y-4">
                                {canSeeContent ? (
                                    course.lessons && course.lessons.length > 0 ? (
                                        course.lessons.map((lesson: any, i: number) => (
                                            <AccordionItem key={lesson.id} lesson={lesson} index={i + 1} />
                                        ))
                                    ) : (
                                        <div className="p-10 text-center bg-surface-container-low rounded-xl border border-dashed border-outline">
                                            No lessons uploaded yet.
                                        </div>
                                    )
                                ) : (
                                    <div className="text-center py-12 bg-surface-container-low rounded-3xl border-2 border-dashed border-outline-variant/30">
                                        <div className="w-16 h-16 bg-primary-container/20 rounded-full flex items-center justify-center mx-auto mb-4">
                                            <span className="material-symbols-outlined text-primary text-3xl">
                                                {isRejected ? 'block' : 'lock'}
                                            </span>
                                        </div>
                                        <h3 className="text-lg font-bold text-primary mb-2">
                                            {isRejected ? 'Access Denied' : 'Content Locked'}
                                        </h3>
                                        <p className="text-on-surface-variant max-w-md mx-auto">
                                            {isRejected 
                                                ? 'The teacher has prevented you from accessing this course.' 
                                                : 'Please enroll in this course and wait for teacher approval to access the lessons and materials.'}
                                        </p>
                                    </div>
                                )}
                            </div>
                        </section>
                        {/* END: CourseContentAccordion */}

                        {/* BEGIN: PendingEnrollmentsSection */}
                        {/* {user?.role === 'TEACHER' && (
                            <section className="mb-16">
                                <h2 className="text-2xl font-extrabold text-primary mb-8">Pending Student Requests</h2>
                                {pendingEnrollments.length > 0 ? (
                                    <div className="overflow-hidden bg-surface-container-lowest rounded-2xl border border-outline-variant/30 shadow-sm">
                                        <table className="w-full text-left border-collapse">
                                            <thead>
                                                <tr className="bg-surface-container-low border-b border-outline-variant/30 text-xs font-extrabold uppercase tracking-widest text-on-surface-variant">
                                                    <th className="px-6 py-4">Student Username</th>
                                                    <th className="px-6 py-4">Request Date</th>
                                                    <th className="px-6 py-4 text-right">Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-outline-variant/20">
                                                {pendingEnrollments.map((enrollment) => (
                                                    <tr key={enrollment.id} className="hover:bg-surface-container-low/50 transition-colors">
                                                        <td className="px-6 py-5">
                                                            <div className="flex items-center gap-3">
                                                                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold text-xs">
                                                                    {enrollment.studentUsername.charAt(0).toUpperCase()}
                                                                </div>
                                                                <span className="font-bold text-on-surface">{enrollment.studentUsername}</span>
                                                            </div>
                                                        </td>
                                                        <td className="px-6 py-5 text-sm text-on-surface-variant">
                                                            {new Date(enrollment.requestedAt).toLocaleDateString()}
                                                        </td>
                                                        <td className="px-6 py-5 text-right space-x-2">
                                                            <button
                                                                onClick={() => handleApprove(enrollment.id)}
                                                                className="px-4 py-2 bg-primary/10 text-primary hover:bg-primary hover:text-on-primary rounded-full text-xs font-bold transition-all"
                                                            >
                                                                Accept
                                                            </button>
                                                            <button
                                                                onClick={() => handleReject(enrollment.id)}
                                                                className="px-4 py-2 bg-error-container/20 text-error hover:bg-error hover:text-on-error rounded-full text-xs font-bold transition-all"
                                                            >
                                                                Reject
                                                            </button>
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                ) : (
                                    <div className="p-10 text-center bg-surface-container-low rounded-xl border border-dashed border-outline text-on-surface-variant italic">
                                        No pending student requests at the moment.
                                    </div>
                                )}
                            </section>
                        )} */}
                        {/* END: PendingEnrollmentsSection */}
                    </div>
                    
                    {/* BEGIN: RightSidebar */}
                    <aside className="lg:col-span-4">
                        <div className="sticky top-24 bg-surface-container-lowest border border-outline-variant/30 rounded-2xl p-6 shadow-sm">
                            <h1 className="text-2xl font-extrabold text-primary mb-4">{course.title}</h1>
                            <p className="text-sm text-on-surface-variant mb-8 leading-relaxed">
                                {course.description}
                            </p>
                            
                            <div className="space-y-4 mb-8">
                                {user?.role === 'TEACHER' && (
                                    <button
                                        onClick={() => setShowModal(true)} 
                                        className="w-full py-4 bg-primary text-on-primary font-extrabold rounded-xl hover:opacity-90 transition-all shadow-md"
                                    >
                                        <Plus className="inline-block mr-2" />
                                        Upload Lesson
                                    </button>
                                )}
                                
                                {user?.role === 'STUDENT' && (
                                    <>
                                        {isApproved ? (
                                            <div className="w-full py-4 bg-secondary/10 text-secondary text-center font-extrabold rounded-xl border-2 border-secondary/20">
                                                <span className="material-symbols-outlined align-bottom mr-2">check_circle</span>
                                                Already Enrolled
                                            </div>
                                        ) : isRejected ? (
                                            <div className="w-full py-4 bg-red-100 text-red-600 text-center font-extrabold rounded-xl border-2 border-red-200">
                                                <span className="material-symbols-outlined align-bottom mr-2">block</span>
                                                Access Blocked
                                            </div>
                                        ) : enrollment?.status === 'PENDING' ? (
                                            <div className="w-full py-4 bg-tertiary/10 text-tertiary text-center font-extrabold rounded-xl border-2 border-tertiary/20">
                                                <span className="material-symbols-outlined align-bottom mr-2">hourglass_empty</span>
                                                Enrollment Pending
                                            </div>
                                        ) : (
                                            <button
                                                onClick={handleEnroll}
                                                className="w-full py-4 border-2 border-primary text-primary font-extrabold rounded-xl hover:bg-primary/5 transition-all"
                                            >
                                                Enroll Now
                                            </button>
                                        )}
                                    </>
                                )}
                            </div>
                            
                            <div className="space-y-4 pt-6 border-t border-outline-variant/30">
                                <div className="flex items-center justify-between text-sm">
                                    <span className="flex items-center gap-3 text-on-surface-variant font-medium">
                                        <span className="material-symbols-outlined">menu_book</span>
                                        Lessons
                                    </span>
                                    <span className="font-bold text-primary">{course.lessons?.length || 0} Lessons</span>
                                </div>
                                <div className="flex items-center justify-between text-sm">
                                    <span className="flex items-center gap-3 text-on-surface-variant font-medium">
                                        <span className="material-symbols-outlined">schedule</span>
                                        Duration
                                    </span>
                                    <span className="font-bold text-primary">{course.durationHours || 0} Hours</span>
                                </div>
                            </div>
                        </div>
                    </aside>
                </div>
            </main>
        </>
    );
};

export default CourseDetailsPage
