get '/backstage/?' do
  @db.add_log_entry($log_type[:view_backstage], session[:user_id], "#{session[:display_name]} viewed the backstage index.")
  output = @header
  output << partial(:backstage)
  output << partial(:footer)
  output
end

get '/backstage/warn/?' do
  @db.add_log_entry($log_type[:view_new_warning], session[:user_id], "#{session[:display_name]} viewed the warning creation page.")
  output = @header
  output << partial(:new_warning)
  output << partial(:footer)
  output
end

get '/backstage/warn/saved/?' do
  puts session[:warning_target].inspect
  output = @header
  output << partial(:new_warning_post, :locals => {
    target_username: session[:warning_target][:name],
    message: session[:warning_target][:message],
    note: session[:warning_target][:admin_note]
    })
  output << partial(:footer)
  output
end

get '/backstage/warn/preview/?' do
  output = @header
  output << partial(:generic, :locals => {
    title: 'Error!',
    subhead: '',
    message: 'Must POST to /backstage/warn/preview.',
    link: '/backstage/warn/',
    link_text: 'Return to Warning Creation'
    })
  output << partial(:footer)
  output
end

post '/backstage/warn/preview/?' do
  target = {name: params[:username], message: params[:message], admin_note: params[:admin_note]}
  session[:warning_target] = target

  puts "Target hash: " + target.inspect

  if (!target[:name] || !target[:message] || !target[:admin_note]) then
    redirect to('/backstage/warn/saved/')
  end

  if (target[:name].length < 3 || target[:message].length < 100) then
    redirect to('/backstage/warn/saved')
  end

  output = @header
  output << partial(:warning_preview, :locals => {
    admin_name: session[:display_name],
    send_time: Time.now.strftime('%D'),
    player_name: target[:name],
    message: markdown(target[:message])
    })
  output << partial(:footer)
  output
end

get '/backstage/warn/apply/?' do 
  target = session[:warning_target]

  if (!target[:name] || !target[:message] || !target[:admin_note]) then
    redirect to('/backstage/warn/saved/')
  end

  @db.add_log_entry($log_type[:send_warning], session[:user_id], "#{session[:display_name]} sent a warning to #{target[:name]}.")
  @db.add_warning_minecraft(target[:name], target[:message], target[:admin_note], session[:user_id])

  session[:warning_target] = nil

  output = @header
  output << partial(:generic, :locals => {
    title: 'Warning Added',
    subhead: 'A warning has been added.',
    message: 'A warning has been created. That user cannot log into either Minecraft or Steam games until
    that warning is cleared. Thanks for using Shinda Sekai Sensen.',
    link: '/backstage/',
    link_text: 'Return To Backstage'
    })
  output << partial(:footer)
  output
end