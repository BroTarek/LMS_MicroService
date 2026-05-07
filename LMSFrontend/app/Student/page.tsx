"use client"
import { useEffect, useState } from "react";
import CourseWithProgress from '@/components/CourseWithProgress'
import React from 'react'
import { enrollApi, authApi } from "@/lib/api";
import Link from "next/link";

const StudentDashboard = () => {
    const [user, setUser] = useState<any>(null);
    const [enrolledCourses, setEnrolledCourses] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchProfileAndCourses = async () => {
            try {
                // Try to get profile from backend or localStorage
                const profile = await authApi.getProfile().catch(() => {
                    const local = localStorage.getItem('user');
                    return local ? JSON.parse(local) : null;
                });
                setUser(profile);

                const courses = await enrollApi.myCourses();
                setEnrolledCourses(courses);
            } catch (err) {
                console.error("Failed to fetch student data:", err);
            } finally {
                setLoading(false);
            }
        };

        fetchProfileAndCourses();
    }, []);

    if (loading) return <div className="text-center py-20">Loading dashboard...</div>;

    return (
        <main className="pt-24 pb-32 max-w-screen-2xl mx-auto px-6">
            {/* Profile Header Section */}
            <section className="mb-12">
                <div className="bg-surface-container-low rounded-[2rem] p-8 md:p-12 flex flex-col md:flex-row gap-12 items-start relative overflow-hidden">
                    <div className="relative z-10 w-32 h-32 md:w-48 md:h-48 flex-shrink-0">
                        <div className="w-full h-full rounded-[2.5rem] overflow-hidden shadow-xl">
                            <img alt={user?.username} className="w-full h-full object-cover"
                                src={user?.profileImage || "https://ui-avatars.com/api/?size=256&name=" + (user?.username || "Student")} />
                        </div>
                        <div className="absolute -bottom-2 -right-2 bg-primary p-3 rounded-2xl text-on-primary">
                            <span className="material-symbols-outlined text-xl">verified</span>
                        </div>
                    </div>
                    <div className="flex-grow z-10">
                        <h1 className="text-4xl md:text-5xl font-extrabold text-primary mb-4 tracking-tight">
                            {user?.username || "Student"}
                        </h1>
                        <p className="text-on-surface-variant text-lg max-w-2xl leading-relaxed mb-8">
                            Welcome back to your scholarly dashboard. Here you can track your progress and continue your learning journey.
                        </p>
                        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                            <div className="bg-surface-container-lowest p-6 rounded-3xl">
                                <span className="block text-3xl font-extrabold text-primary mb-1">{enrolledCourses.length}</span>
                                <span className="text-sm font-semibold uppercase tracking-wider text-on-surface-variant opacity-70">Enrolled Courses</span>
                            </div>
                            <div className="bg-surface-container-lowest p-6 rounded-3xl">
                                <span className="block text-3xl font-extrabold text-primary mb-1">0</span>
                                <span className="text-sm font-semibold uppercase tracking-wider text-on-surface-variant opacity-70">Completed</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Main Content Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12">
                <div className="lg:col-span-8">
                    <div className="flex justify-between items-end mb-8">
                        <div>
                            <h2 className="text-3xl font-bold text-primary mb-2">My Courses</h2>
                            <div className="h-1.5 w-12 bg-primary-container rounded-full"></div>
                        </div>
                    </div>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                        {enrolledCourses.length > 0 ? (
                            enrolledCourses.map((course) => (
                                <CourseWithProgress key={course.id} course={course} />
                            ))
                        ) : (
                            <div className="col-span-full text-center py-20 bg-surface-container-lowest rounded-3xl border border-dashed border-outline">
                                <p className="text-on-surface-variant">You are not enrolled in any courses yet.</p>
                                <Link href="/" className="inline-block mt-4 text-primary font-bold hover:underline">Browse Courses</Link>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </main>
    )
}

export default StudentDashboard