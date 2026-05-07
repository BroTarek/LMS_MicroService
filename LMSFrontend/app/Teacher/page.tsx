"use client"
import { useEffect, useState } from "react";
import CourseCard from '@/components/CourseCard'
import Modal from '@/components/Modal'
import { Plus } from 'lucide-react'
import React from 'react'
import { courseApi, authApi } from "@/lib/api";

const TeacherDashboard = () => {
    const [user, setUser] = useState<any>(null);
    const [myCourses, setMyCourses] = useState<any[]>([]);
    const [pendingEnrollments, setPendingEnrollments] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);

    const fetchCoursesAndRequests = async () => {
        try {
            const courses = await courseApi.myCourses();
            setMyCourses(courses);

            // Fetch pending enrollments for all courses
            const allPending = await Promise.all(
                courses.map(async (course: any) => {
                    const pending = await enrollApi.pending(course.id);
                    return pending.map((p: any) => ({ ...p, courseTitle: course.title }));
                })
            );
            setPendingEnrollments(allPending.flat());
        } catch (err) {
            console.error("Failed to fetch teacher dashboard data:", err);
        } finally {
            setLoading(false);
        }
    };

    const handleEnrollmentAction = async (id: number, action: 'approve' | 'reject') => {
        try {
            if (action === 'approve') await enrollApi.approve(id);
            else await enrollApi.reject(id);
            fetchCoursesAndRequests(); // Refresh
        } catch (err) {
            console.error(`Failed to ${action} enrollment:`, err);
        }
    };

    useEffect(() => {
        const local = localStorage.getItem('user');
        if (local) setUser(JSON.parse(local));
        fetchCoursesAndRequests();
    }, []);

    if (loading) return <div className="text-center py-20">Loading teacher dashboard...</div>;

    return (
        <main className="pt-24 pb-32 max-w-screen-2xl mx-auto px-6">
            {showModal && <Modal handleModalVisisbility={() => setShowModal(false)} />}
            
            <section className="mb-12">
                <div className="bg-primary-container/20 rounded-[2rem] p-8 md:p-12 flex flex-col md:flex-row justify-between items-center gap-8">
                    <div>
                        <h1 className="text-4xl md:text-5xl font-extrabold text-primary mb-4 tracking-tight">
                            Teacher Dashboard
                        </h1>
                        <p className="text-on-surface-variant text-lg max-w-2xl">
                            Manage your courses and inspire students globally.
                        </p>
                    </div>
                    <button 
                        onClick={() => setShowModal(true)}
                        className="flex items-center gap-2 px-8 py-4 bg-primary text-on-primary font-bold rounded-2xl hover:shadow-lg transition-all"
                    >
                        <Plus size={20} />
                        Create New Course
                    </button>
                </div>
            </section>

            {/* Pending Requests Section */}
            {pendingEnrollments.length > 0 && (
                <section className="mb-16">
                    <h2 className="text-3xl font-bold text-primary mb-8">Enrollment Requests</h2>
                    <div className="bg-surface-container-lowest rounded-[2rem] border border-outline-variant/20 overflow-hidden">
                        <div className="overflow-x-auto">
                            <table className="w-full text-left border-collapse">
                                <thead className="bg-surface-container-low">
                                    <tr>
                                        <th className="p-6 text-xs font-bold uppercase tracking-wider text-on-surface-variant">Student</th>
                                        <th className="p-6 text-xs font-bold uppercase tracking-wider text-on-surface-variant">Course</th>
                                        <th className="p-6 text-xs font-bold uppercase tracking-wider text-on-surface-variant">Status</th>
                                        <th className="p-6 text-xs font-bold uppercase tracking-wider text-on-surface-variant text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-outline-variant/10">
                                    {pendingEnrollments.map((req) => (
                                        <tr key={req.id} className="hover:bg-surface-container-low/30 transition-colors">
                                            <td className="p-6">
                                                <div className="font-bold text-primary">{req.studentUsername}</div>
                                            </td>
                                            <td className="p-6">
                                                <div className="text-on-surface-variant">{req.courseTitle}</div>
                                            </td>
                                            <td className="p-6">
                                                <span className="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-xs font-bold uppercase tracking-widest">Pending</span>
                                            </td>
                                            <td className="p-6 text-right space-x-2">
                                                <button 
                                                    onClick={() => handleEnrollmentAction(req.id, 'approve')}
                                                    className="px-4 py-2 bg-green-600 text-white text-xs font-bold rounded-lg hover:bg-green-700 transition-all"
                                                >
                                                    Approve
                                                </button>
                                                <button 
                                                    onClick={() => handleEnrollmentAction(req.id, 'reject')}
                                                    className="px-4 py-2 bg-red-600 text-white text-xs font-bold rounded-lg hover:bg-red-700 transition-all"
                                                >
                                                    Reject
                                                </button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            )}

            <section>
                <div className="flex items-center justify-between mb-8">
                    <h2 className="text-3xl font-bold text-primary">My Courses</h2>
                    <span className="text-on-surface-variant font-medium">{myCourses.length} Courses Published</span>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {myCourses.length > 0 ? (
                        myCourses.map(course => (
                            <CourseCard key={course.id} course={course} />
                        ))
                    ) : (
                        <div className="col-span-full text-center py-32 bg-surface-container-low rounded-3xl border-2 border-dashed border-outline-variant">
                            <p className="text-on-surface-variant text-lg">You haven't created any courses yet.</p>
                            <button 
                                onClick={() => setShowModal(true)}
                                className="mt-4 text-primary font-bold hover:underline"
                            >
                                Start your first course
                            </button>
                        </div>
                    )}
                </div>
            </section>
        </main>
    );
};

export default TeacherDashboard;
