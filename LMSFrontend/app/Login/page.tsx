"use client"
import Link from 'next/link'
import React, { useState } from 'react'
import { useRouter } from 'next/navigation'
import { authApi } from '@/lib/api'

const LoginPage = () => {
    const router = useRouter()
    const [formData, setFormData] = useState({ username: '', password: '' })
    const [error, setError] = useState('')
    const [loading, setLoading] = useState(false)

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData({ ...formData, [e.target.name]: e.target.value })
    }

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        setError('')
        setLoading(true)

        try {
            const data = await authApi.login(formData)
            localStorage.setItem('token', data.token)
            localStorage.setItem('user', JSON.stringify({
                username: data.username,
                role: data.role
            }))
            router.push('/')
        } catch (err: any) {
            setError(err.message || 'Login failed. Please check your credentials.')
        } finally {
            setLoading(false)
        }
    }

    return (
        <>
            <div className="bg-background text-on-background min-h-screen flex items-center justify-center p-4 md:p-8">
                <main className="w-full max-w-7xl grid grid-cols-1 md:grid-cols-12 gap-0 overflow-hidden bg-surface-container-lowest rounded-3xl shadow-ambient">
                    {/* Brand Side */}
                    <div className="hidden md:flex md:col-span-5 relative bg-primary-container overflow-hidden items-center justify-center p-16">
                        <div className="absolute inset-0 z-0 opacity-40">
                            <img className="w-full h-full object-cover"
                                alt="library"
                                src="https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=800" />
                        </div>
                        <div className="absolute inset-0 bg-gradient-to-tr from-primary-container via-primary-container/80 to-transparent z-10"></div>
                        <div className="relative z-20 text-white max-w-sm">
                            <div className="mb-8">
                                <span className="text-4xl font-extrabold tracking-tighter text-on-primary-container">Yanfaa</span>
                            </div>
                            <h2 className="text-4xl font-extrabold text-editorial-anchor leading-tight mb-6">Invest in your future.</h2>
                            <p className="text-lg text-on-primary-container font-medium opacity-90 leading-relaxed">
                                Access the global archive of curated research, mentorship, and academic excellence.
                            </p>
                        </div>
                    </div>

                    {/* Form Side */}
                    <div className="col-span-1 md:col-span-7 flex flex-col justify-center p-8 md:p-24 bg-surface-container-lowest">
                        <div className="md:hidden mb-12">
                            <span className="text-2xl font-extrabold tracking-tighter text-primary">Yanfaa</span>
                        </div>
                        <div className="max-w-md w-full mx-auto">
                            <header className="mb-10">
                                <h1 className="text-4xl font-extrabold text-primary text-editorial-anchor mb-3">Welcome Back</h1>
                                <p className="text-on-surface-variant text-lg">Please authenticate to access your dashboard.</p>
                            </header>

                            {error && (
                                <div className="mb-6 p-4 bg-red-100 text-red-700 rounded-xl text-sm font-bold">
                                    {error}
                                </div>
                            )}

                            <form className="space-y-6" onSubmit={handleSubmit}>
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-primary tracking-wide uppercase opacity-70" htmlFor="username">Username</label>
                                    <div className="relative">
                                        <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">person</span>
                                        <input
                                            className="w-full pl-12 pr-4 py-4 bg-surface-container-low ghost-border rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent transition-all outline-none text-on-surface"
                                            id="username" name="username" placeholder="your_username" type="text" required 
                                            value={formData.username} onChange={handleChange} />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <div className="flex justify-between items-center">
                                        <label className="text-sm font-bold text-primary tracking-wide uppercase opacity-70" htmlFor="password">Password</label>
                                    </div>
                                    <div className="relative">
                                        <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">lock</span>
                                        <input
                                            className="w-full pl-12 pr-12 py-4 bg-surface-container-low ghost-border rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent transition-all outline-none text-on-surface"
                                            id="password" name="password" placeholder="••••••••••••" type="password" required
                                            value={formData.password} onChange={handleChange} />
                                    </div>
                                </div>
                                
                                <button
                                    disabled={loading}
                                    className="w-full py-4 px-6 bg-gradient-to-r from-primary to-primary-container text-on-primary font-bold rounded-full text-lg shadow-ambient hover:opacity-90 active:scale-[0.98] transition-all disabled:opacity-50"
                                    type="submit">
                                    {loading ? 'Authenticating...' : 'Sign In'}
                                </button>
                            </form>

                            <footer className="mt-12 text-center">
                                <p className="text-on-surface-variant font-medium">
                                    New to the institution?
                                    <Link className="text-primary font-bold hover:underline underline-offset-4 ml-1" href="/Registeration">Sign Up</Link>
                                </p>
                            </footer>
                        </div>
                    </div>
                </main>
            </div>
        </>
    )
}

export default LoginPage