Rails.application.routes.draw do
  get("/", { :controller => "reports", :action => "index" })

  post("/insert_report", { :controller => "reports", :action => "create" })

  get("/reports", { :controller => "reports", :action => "index" })
end
