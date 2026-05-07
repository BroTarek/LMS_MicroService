"use client"
import React, { useState } from 'react'

interface AccordionItemProps {
    lesson: {
        id: number;
        title: string;
        contentUrl?: string;
        videoUrl?: string;
    },
    index: number;
}

const AccordionItem = ({ lesson, index }: AccordionItemProps) => {
    const [isOpen, setIsOpen] = useState(false);
    const [downloading, setDownloading] = useState(false);

    const handleDownload = async () => {
        if (!lesson.contentUrl) return;
        
        const isInternalFile = lesson.contentUrl.startsWith('/api/uploads') || 
                               lesson.contentUrl.includes(':8080/api/uploads') || 
                               lesson.contentUrl.includes(':8084/api/uploads');

        if (!isInternalFile) {
            window.open(lesson.contentUrl, '_blank');
            return;
        }

        setDownloading(true);
        try {
            const token = localStorage.getItem('token');
            const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://127.0.0.1:8080';
            
            const fullUrl = lesson.contentUrl.startsWith('http') 
                ? lesson.contentUrl 
                : `${API_URL}${lesson.contentUrl}`;

            const response = await fetch(fullUrl, {
                headers: {
                    ...(token ? { 'Authorization': `Bearer ${token}` } : {})
                }
            });

            if (!response.ok) throw new Error('Download failed');

            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            
            const disposition = response.headers.get('Content-Disposition');
            let filename = `lesson-${lesson.id}-file`;
            if (disposition && disposition.indexOf('attachment') !== -1) {
                const filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
                const matches = filenameRegex.exec(disposition);
                if (matches != null && matches[1]) {
                    filename = matches[1].replace(/['"]/g, '');
                }
            }
            
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        } catch (err) {
            console.error("Download error:", err);
            alert("Failed to download file.");
        } finally {
            setDownloading(false);
        }
    };

    const isInternalFile = lesson.contentUrl?.startsWith('/api/uploads') || 
                          lesson.contentUrl?.includes('/api/uploads');

    return (
        <>
            <div className={`accordion-item border border-outline-variant/30 rounded-xl overflow-hidden bg-surface-container-lowest shadow-sm ${isOpen ? 'ring-2 ring-primary/20' : ''}`}>
                <button
                    className="w-full flex items-center justify-between p-5 text-left bg-surface-container-lowest hover:bg-surface-container-low transition-colors"
                    onClick={() => setIsOpen(!isOpen)} >
                    <div className="flex items-center gap-4">
                        <span
                            className="flex items-center justify-center w-8 h-8 rounded-full bg-primary text-on-primary text-xs font-bold"
                        >{index < 10 ? `0${index}` : index}</span>
                        <span className="font-bold text-primary">{lesson.title}</span>
                    </div>
                    <svg className={`w-5 h-5 text-outline transition-transform ${isOpen ? 'rotate-180' : ''}`} fill="none"
                        stroke="currentColor" viewBox="0 0 24 24">
                        <path d="M19 9l-7 7-7-7" strokeLinecap="round" strokeLinejoin="round"
                            strokeWidth="2"></path>
                    </svg>
                </button>
                {isOpen && (
                    <div className="accordion-content border-t border-outline-variant/30 bg-surface-container-low/30">
                        <div className="p-6">
                            <div className="flex flex-wrap gap-4">
                                {lesson.contentUrl && (
                                    <button 
                                        onClick={handleDownload}
                                        disabled={downloading}
                                        className="inline-flex items-center gap-2 px-6 py-2 bg-primary text-on-primary rounded-full text-xs font-bold hover:opacity-90 transition-all disabled:opacity-50"
                                    >
                                        <span className="material-symbols-outlined text-sm">
                                            {downloading ? 'sync' : (isInternalFile ? 'download' : 'open_in_new')}
                                        </span>
                                        {downloading ? 'DOWNLOADING...' : (isInternalFile ? 'DOWNLOAD DOCUMENT' : 'VIEW MATERIAL')}
                                    </button>
                                )}
                                {lesson.videoUrl && (
                                    <a className="inline-flex items-center gap-2 px-6 py-2 bg-secondary text-on-secondary rounded-full text-xs font-bold hover:opacity-90 transition-all"
                                        href={lesson.videoUrl} target="_blank">
                                        <span className="material-symbols-outlined text-sm">play_circle</span>
                                        WATCH LESSON
                                    </a>
                                )}
                                {!lesson.contentUrl && !lesson.videoUrl && (
                                    <p className="text-on-surface-variant text-sm italic">
                                        No materials attached to this lesson.
                                    </p>
                                )}
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </>
    )
}

export default AccordionItem