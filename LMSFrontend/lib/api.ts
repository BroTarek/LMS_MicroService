const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://127.0.0.1:8080';

export async function apiRequest(endpoint: string, options: RequestInit = {}) {
  const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
  const userJson = typeof window !== 'undefined' ? localStorage.getItem('user') : null;
  const user = userJson ? JSON.parse(userJson) : null;

  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
    ...(user?.username ? { 'X-Username': user.username } : {}),
    ...(user?.role ? { 'X-Role': user.role } : {}),
    ...options.headers,
  };

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers,
  });

  if (response.status === 401) {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      // Optional: redirect to login
    }
  }

  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: 'An error occurred' }));
    throw new Error(error.message || response.statusText);
  }

  if (response.status === 204 || (response.ok && response.status === 200 && response.headers.get('Content-Length') === '0')) return null;
  
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}

export const authApi = {
  login: (credentials: any) => apiRequest('/auth/login', { method: 'POST', body: JSON.stringify(credentials) }),
  register: (data: any) => apiRequest('/auth/register', { method: 'POST', body: JSON.stringify(data) }),
  logout: () => apiRequest('/auth/logout', { method: 'POST' }),
  getProfile: () => apiRequest('/api/users/me'),
};

export const courseApi = {
  list: () => apiRequest('/api/courses'),
  myCourses: () => apiRequest('/api/courses/my'),
  get: (id: string) => apiRequest(`/api/courses/${id}`),
  create: (data: any) => {
    
    return apiRequest('/api/courses', { method: 'POST', body: JSON.stringify(data) })
},
  addLesson: (courseId: string, data: any) => {
    console.log(data)
    return apiRequest(`/api/courses/${courseId}/lessons`, { method: 'POST', body: JSON.stringify(data) })
  },
};

export const enrollApi = {
  request: (courseId: number) => apiRequest('/api/enrollments', { method: 'POST', body: JSON.stringify({ courseId }) }),
  pending: (courseId: number) => apiRequest(`/api/enrollments/pending?courseId=${courseId}`),
  approve: (id: number) => apiRequest(`/api/enrollments/${id}/approve`, { method: 'POST' }),
  reject: (id: number) => apiRequest(`/api/enrollments/${id}/reject`, { method: 'POST' }),
  myCourses: () => apiRequest('/api/enrollments/my-courses'),
  enrollments:(courseId: number)=>{
    const res=apiRequest(`/api/enrollments/enrolledStudents?courseId=${courseId}`)
    console.log(res)
    return res
  }
};

export const uploadApi = {
  upload: async (file: File, courseId?: number) => {
    const formData = new FormData();
    formData.append('file', file);
    if (courseId) formData.append('courseId', courseId.toString());

    const token = typeof window !== 'undefined' ? localStorage.getItem('token') : null;
    const response = await fetch(`${API_URL}/api/uploads`, {
      method: 'POST',
      headers: {
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: formData,
    });
    const clonedResponse=response.clone()
    if (!response.ok) throw new Error('Upload failed');
    console.log(clonedResponse.json())
    return response.json();
  },
};
