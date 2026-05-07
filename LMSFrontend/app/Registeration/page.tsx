"use client"
import Link from "next/link";
import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { authApi } from "@/lib/api";

const RegisterPage = () => {
  const router = useRouter();
  const [formData, setFormData] = useState({
    username: "",
    fullName: "",
    email: "",
    password: "",
    role: "STUDENT"
  });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    console.log(formData)
    setError("");
    setLoading(true);

    try {
      await authApi.register(formData);
      router.push("/Login");
    } catch (err: any) {
      setError(err.message || "Registration failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-background text-on-background antialiased selection:bg-primary-fixed selection:text-on-primary-fixed">
      <main className="min-h-screen flex flex-col md:flex-row editorial-gradient">
        {/* Left Column */}
        <div className="hidden md:flex md:w-5/12 lg:w-1/2 p-12 lg:p-24 flex-col justify-between relative overflow-hidden bg-primary-container text-on-primary">
          <div className="z-10">
            <div className="text-3xl font-extrabold tracking-tighter mb-16">Yanfaa</div>
            <h1 className="text-5xl lg:text-7xl font-bold tracking-tight mb-8 leading-tight">
              Join the <span className="text-on-primary-container">Future</span> of Learning.
            </h1>
            <p className="text-lg lg:text-xl text-on-primary-container/80 max-w-md font-light leading-relaxed">
              Join a distinguished global community of researchers, curators, and mentors.
            </p>
          </div>
          <div className="absolute inset-0 bg-gradient-to-br from-primary-container via-primary-container to-transparent opacity-90"></div>
        </div>

        {/* Right Column */}
        <div className="w-full md:w-7/12 lg:w-1/2 flex items-center justify-center p-6 sm:p-12 lg:p-24 bg-surface-bright">
          <div className="w-full max-w-md">
            <div className="md:hidden text-2xl font-extrabold tracking-tighter text-primary-container mb-12">Yanfaa</div>
            <div className="mb-10">
              <h2 className="text-3xl lg:text-4xl font-extrabold tracking-tight text-primary mb-3">Create Account</h2>
              <p className="text-on-surface-variant leading-relaxed">Begin your journey today.</p>
            </div>

            {error && (
              <div className="mb-6 p-4 bg-red-100 text-red-700 rounded-xl text-sm font-bold">
                {error}
              </div>
            )}

            <form className="space-y-5" onSubmit={handleSubmit}>
              <div className="space-y-1.5">
                <label className="text-xs font-bold uppercase tracking-wider text-on-surface-variant ml-4">Role</label>
                <div className="relative">
                  <span className="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-primary/40 text-lg">supervised_user_circle</span>
                  <select
                    name="role"
                    value={formData.role}
                    onChange={handleChange}
                    className="w-full pl-14 pr-10 py-4 bg-surface-container-lowest rounded-full border-none ring-1 ring-outline-variant/30 focus:ring-2 focus:ring-primary-container/40 transition-all outline-none text-on-surface appearance-none">
                    <option value="STUDENT">Student</option>
                    <option value="TEACHER">Teacher</option>
                  </select>
                  <span className="material-symbols-outlined absolute right-5 top-1/2 -translate-y-1/2 text-on-surface-variant/40 pointer-events-none">expand_more</span>
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold uppercase tracking-wider text-on-surface-variant ml-4">Full Name</label>
                <div className="relative">
                  <span className="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-primary/40 text-lg">badge</span>
                  <input
                    name="fullName"
                    value={formData.fullName}
                    onChange={handleChange}
                    required
                    className="w-full pl-14 pr-6 py-4 bg-surface-container-lowest rounded-full border-none ring-1 ring-outline-variant/30 focus:ring-2 focus:ring-primary-container/40 transition-all outline-none text-on-surface"
                    placeholder="John Doe"
                    type="text"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold uppercase tracking-wider text-on-surface-variant ml-4">Username</label>
                <div className="relative">
                  <span className="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-primary/40 text-lg">person</span>
                  <input
                    name="username"
                    value={formData.username}
                    onChange={handleChange}
                    required
                    className="w-full pl-14 pr-6 py-4 bg-surface-container-lowest rounded-full border-none ring-1 ring-outline-variant/30 focus:ring-2 focus:ring-primary-container/40 transition-all outline-none text-on-surface"
                    placeholder="your_username"
                    type="text"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold uppercase tracking-wider text-on-surface-variant ml-4">Email</label>
                <div className="relative">
                  <span className="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-primary/40 text-lg">mail</span>
                  <input
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    required
                    className="w-full pl-14 pr-6 py-4 bg-surface-container-lowest rounded-full border-none ring-1 ring-outline-variant/30 focus:ring-2 focus:ring-primary-container/40 transition-all outline-none text-on-surface"
                    placeholder="name@example.com"
                    type="email"
                  />
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold uppercase tracking-wider text-on-surface-variant ml-4">Password</label>
                <div className="relative">
                  <span className="material-symbols-outlined absolute left-5 top-1/2 -translate-y-1/2 text-primary/40 text-lg">lock</span>
                  <input
                    name="password"
                    value={formData.password}
                    onChange={handleChange}
                    required
                    className="w-full pl-14 pr-14 py-4 bg-surface-container-lowest rounded-full border-none ring-1 ring-outline-variant/30 focus:ring-2 focus:ring-primary-container/40 transition-all outline-none text-on-surface"
                    placeholder="••••••••••••"
                    type="password"
                  />
                </div>
              </div>

              <div className="pt-4">
                <button
                  disabled={loading}
                  className="w-full py-4 bg-gradient-to-r from-primary to-primary-container text-on-primary font-bold rounded-full shadow-lg hover:scale-[1.01] active:scale-95 transition-all duration-300 disabled:opacity-50"
                  type="submit"
                >
                  {loading ? "Creating Account..." : "Join Yanfaa"}
                </button>
              </div>
            </form>

            <p className="mt-10 text-center text-on-surface-variant text-sm font-medium">
              Already a member?
              <Link className="text-primary-container font-extrabold hover:underline underline-offset-4 decoration-2 ml-1" href="/Login">
                Sign In
              </Link>
            </p>
          </div>
        </div>
      </main>
    </div>
  );
};

export default RegisterPage;