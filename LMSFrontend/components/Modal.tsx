"use client"
import React, { useState } from 'react'
import { courseApi, uploadApi } from '@/lib/api'

type ModalProps = {
    handleModalVisisbility: () => void;
    type?: 'course' | 'lesson';
    courseId?: string;
}

const Modal = ({ handleModalVisisbility, type = 'course', courseId }: ModalProps) => {
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        contentUrl: '',
        orderIndex: 1
    });
    const [file, setFile] = useState<File | null>(null);
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            if (type === 'course') {
                await courseApi.create({
                    title: formData.title,
                    description: formData.description
                });
            } else if (courseId) {
                let finalUrl = formData.contentUrl;
                
                // If a file is selected, upload it first
                if (file) {
                    const uploadResponse = await uploadApi.upload(file, Number(courseId));
                    console.log(uploadResponse)
                    finalUrl = uploadResponse.url || uploadResponse.filePath;
                    console.log(finalUrl)
                }

                await courseApi.addLesson(courseId, {
                    title: formData.title,
                    contentUrl: finalUrl,
                    orderIndex: formData.orderIndex
                });
            }
            handleModalVisisbility();
            // window.location.reload();
        } catch (err) {
            console.error("Failed to save:", err);
            alert("Failed to save. Please try again.");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/40 backdrop-blur-sm" onClick={handleModalVisisbility}></div>
            <div className="relative bg-surface-container-lowest w-full max-w-xl rounded-[2.5rem] shadow-2xl overflow-hidden border border-outline-variant/20">
                <div className="bg-primary p-8 text-on-primary">
                    <div className="flex justify-between items-center">
                        <h2 className="text-2xl font-extrabold tracking-tight">
                            {type === 'course' ? 'Create New Course' : 'Add New Lesson'}
                        </h2>
                        <button onClick={handleModalVisisbility} className="w-10 h-10 rounded-full flex items-center justify-center hover:bg-white/10 transition-all">
                            <span className="material-symbols-outlined">close</span>
                        </button>
                    </div>
                </div>

                <form className="p-8 space-y-6" onSubmit={handleSubmit}>
                    <div className="space-y-2">
                        <label className="text-xs font-extrabold uppercase tracking-widest text-on-surface-variant block ml-1">
                            {type === 'course' ? 'Course Title' : 'Lesson Title'}
                        </label>
                        <input
                            required
                            value={formData.title}
                            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                            className="w-full bg-surface-container-low rounded-2xl p-4 text-primary font-medium outline-none focus:ring-2 focus:ring-primary/20 transition-all"
                            placeholder={type === 'course' ? "e.g. Master English in 30 Days" : "e.g. Introduction to Grammar"}
                            type="text"
                        />
                    </div>

                    {type === 'course' ? (
                        <div className="space-y-2">
                            <label className="text-xs font-extrabold uppercase tracking-widest text-on-surface-variant block ml-1">
                                Description
                            </label>
                            <textarea
                                required
                                value={formData.description}
                                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                className="w-full bg-surface-container-low rounded-2xl p-4 text-primary font-medium outline-none focus:ring-2 focus:ring-primary/20 transition-all resize-none"
                                placeholder="Briefly describe the objectives..."
                                rows={4}
                            ></textarea>
                        </div>
                    ) : (
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <label className="text-xs font-extrabold uppercase tracking-widest text-on-surface-variant block ml-1">
                                    Lesson File
                                </label>
                                <div className="relative group">
                                    <input 
                                        type="file" 
                                        onChange={(e) => setFile(e.target.files ? e.target.files[0] : null)}
                                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10" 
                                    />
                                    <div className="border-2 border-dashed border-outline-variant rounded-2xl p-8 flex flex-col items-center justify-center gap-3 bg-surface-container-low group-hover:bg-surface-container transition-colors">
                                        <div className="w-12 h-12 rounded-full bg-primary-container flex items-center justify-center text-primary">
                                            <span className="material-symbols-outlined">cloud_upload</span>
                                        </div>
                                        <div className="text-center">
                                            <p className="text-sm font-bold text-primary">
                                                {file ? file.name : 'Click to upload or drag & drop'}
                                            </p>
                                            <p className="text-xs text-on-surface-variant mt-1">Video, PDF, or Document</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="space-y-2">
                                <label className="text-xs font-extrabold uppercase tracking-widest text-on-surface-variant block ml-1">
                                    OR Content URL
                                </label>
                                <input
                                    value={formData.contentUrl}
                                    onChange={(e) => setFormData({ ...formData, contentUrl: e.target.value })}
                                    className="w-full bg-surface-container-low rounded-2xl p-4 text-primary font-medium outline-none focus:ring-2 focus:ring-primary/20 transition-all"
                                    placeholder="https://..."
                                    type="text"
                                />
                            </div>
                        </div>
                    )}

                    <div className="flex items-center justify-end gap-4 pt-4 border-t border-outline-variant/10">
                        <button
                            type="button"
                            onClick={handleModalVisisbility}
                            className="px-8 py-3 rounded-full font-bold text-on-surface-variant hover:bg-surface-container transition-all"
                        >
                            Cancel
                        </button>
                        <button
                            disabled={loading}
                            className="bg-primary text-on-primary px-10 py-3.5 rounded-full font-bold shadow-md hover:shadow-lg transition-all active:scale-95 disabled:opacity-50"
                            type="submit"
                        >
                            {loading ? 'Saving...' : type === 'course' ? 'Create Course' : 'Save Lesson'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    )
}

export default Modal