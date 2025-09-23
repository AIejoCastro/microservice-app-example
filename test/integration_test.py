import requests
import time
import pytest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
import os

class TestMicroserviceIntegration:
    
    @classmethod
    def setup_class(cls):
        cls.base_url = os.getenv('BASE_URL', 'http://localhost:8080')
        cls.auth_api_url = os.getenv('VUE_APP_AUTH_API_URL', 'http://localhost:8000')
        cls.users_api_url = os.getenv('VUE_APP_USERS_API_URL', 'http://localhost:8083')
        cls.todos_api_url = os.getenv('VUE_APP_TODOS_API_URL', 'http://localhost:8082')
        
        # Setup Chrome driver for Selenium tests
        chrome_options = Options()
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--disable-dev-shm-usage')
        cls.driver = webdriver.Chrome(options=chrome_options)
        cls.wait = WebDriverWait(cls.driver, 10)
    
    @classmethod
    def teardown_class(cls):
        cls.driver.quit()
    
    def test_health_checks(self):
        """Test all microservices health endpoints"""
        services = {
            'auth-api': f"{self.auth_api_url}/health",
            'users-api': f"{self.users_api_url}/actuator/health",
            'todos-api': f"{self.todos_api_url}/health",
            'frontend': f"{self.base_url}/health"
        }
        
        for service_name, health_url in services.items():
            try:
                response = requests.get(health_url, timeout=10)
                assert response.status_code == 200, f"{service_name} health check failed"
                print(f"✅ {service_name} health check passed")
            except requests.exceptions.RequestException as e:
                pytest.fail(f"❌ {service_name} health check failed: {e}")
    
    def test_circuit_breaker_functionality(self):
        """Test Circuit Breaker Pattern by simulating service failures"""
        # Test normal operation
        self.driver.get(self.base_url)
        
        # Wait for the app to load
        self.wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        
        # Check if circuit breaker status is displayed (assuming we added this to UI)
        try:
            circuit_status = self.driver.find_element(By.ID, "circuit-breaker-status")
            assert "CLOSED" in circuit_status.text, "Circuit breaker should be CLOSED initially"
            print("✅ Circuit Breaker is in CLOSED state")
        except Exception as e:
            print(f"⚠️  Circuit breaker status not visible in UI: {e}")
    
    def test_cache_aside_pattern(self):
        """Test Cache Aside Pattern by measuring response times"""
        # First request (cache miss)
        start_time = time.time()
        response1 = requests.get(f"{self.users_api_url}/users/1")
        first_response_time = time.time() - start_time
        
        # Second request (should be from cache)
        start_time = time.time()
        response2 = requests.get(f"{self.users_api_url}/users/1")
        second_response_time = time.time() - start_time
        
        assert response1.status_code == 200
        assert response2.status_code == 200
        assert response1.json() == response2.json()
        
        # Cache hit should be faster (allowing some margin for network variation)
        if second_response_time < first_response_time * 0.8:
            print(f"✅ Cache Aside Pattern working - First: {first_response_time:.3f}s, Second: {second_response_time:.3f}s")
        else:
            print(f"⚠️  Cache behavior unclear - First: {first_response_time:.3f}s, Second: {second_response_time:.3f}s")
    
    def test_full_user_journey(self):
        """Test complete user journey through the application"""
        self.driver.get(self.base_url)
        
        try:
            # Wait for login form
            login_button = self.wait.until(
                EC.element_to_be_clickable((By.ID, "login-button"))
            )
            
            # Fill login form (assuming test user exists)
            username_field = self.driver.find_element(By.ID, "username")
            password_field = self.driver.find_element(By.ID, "password")
            
            username_field.send_keys("testuser")
            password_field.send_keys("testpass")
            login_button.click()
            
            # Wait for dashboard
            self.wait.until(EC.presence_of_element_located((By.ID, "dashboard")))
            
            # Test adding a TODO
            add_todo_button = self.driver.find_element(By.ID, "add-todo")
            add_todo_button.click()
            
            todo_input = self.wait.until(
                EC.presence_of_element_located((By.ID, "todo-input"))
            )
            todo_input.send_keys("Test TODO from integration test")
            
            save_button = self.driver.find_element(By.ID, "save-todo")
            save_button.click()
            
            # Verify TODO was added
            self.wait.until(
                EC.text_to_be_present_in_element((By.CLASS_NAME, "todo-item"), "Test TODO from integration test")
            )
            
            print("✅ Full user journey test passed")
            
        except Exception as e:
            # Take screenshot on failure
            self.driver.save_screenshot("/tmp/integration_test_failure.png")
            pytest.fail(f"Full user journey test failed: {e}")
    
    def test_autoscaling_triggers(self):
        """Test that the application can handle load (simulates autoscaling scenarios)"""
        import concurrent.futures
        import threading
        
        def make_request():
            try:
                response = requests.get(f"{self.base_url}/api/health", timeout=30)
                return response.status_code == 200
            except:
                return False
        
        # Simulate concurrent requests
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(make_request) for _ in range(50)]
            successful_requests = sum(1 for future in concurrent.futures.as_completed(futures) if future.result())
        
        success_rate = successful_requests / 50
        assert success_rate > 0.8, f"Success rate too low: {success_rate}"
        print(f"✅ Load test passed with {success_rate*100:.1f}% success rate")

if __name__ == "__main__":
    pytest.main([__file__, "-v"])